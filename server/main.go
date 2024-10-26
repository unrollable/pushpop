package main

import (
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"sync"

	"github.com/gin-gonic/gin"
)

type Message struct {
	ApiKey  string `json:"apikey"`
	Type    string `json:"type"`
	Title   string `json:"title"`
	Content string `json:"content"`
}

var (
	clients      = make(map[string]chan Message)
	mu           sync.Mutex
	messageQueue = make(chan Message)
)

func main() {
	router := gin.Default()

	router.GET("/events/:apikey", handleEvents)
	router.POST("/message/push", handleMessage)

	go processMessages()

	router.Run(":8080")
}

func handleEvents(c *gin.Context) {
	apikey := c.Param("apikey")
	messageChan := make(chan Message)

	mu.Lock()
	clients[apikey] = messageChan
	mu.Unlock()

	defer func() {
		mu.Lock()
		delete(clients, apikey)
		close(messageChan)
		mu.Unlock()
	}()

	c.Header("Content-Type", "text/event-stream")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")

	flusher, ok := c.Writer.(http.Flusher)
	if !ok {
		http.Error(c.Writer, "Streaming unsupported!", http.StatusInternalServerError)
		return
	}
	fmt.Println("client [", apikey, "] is listening...")
	c.Stream(func(w io.Writer) bool {
		fmt.Fprintf(w, "event: message\n")
		for {
			select {
			case message, ok := <-messageChan:
				if !ok {
					return false
				}
				messageJSON, err := json.Marshal(message)
				if err != nil {
					fmt.Println("Error marshaling message:", err)
					continue
				}
				fmt.Fprintf(w, "data: %s\n\n", messageJSON)
				flusher.Flush()
			}
		}
	})
}

func handleMessage(c *gin.Context) {
	var msg Message
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	messageQueue <- msg
	c.JSON(http.StatusOK, gin.H{"status": "Success"})
}

func processMessages() {
	for {
		msg := <-messageQueue
		mu.Lock()
		clientChan, exists := clients[msg.ApiKey]
		if exists {
			clientChan <- msg
		} else {
			fmt.Println("No clients for API key:", msg.ApiKey)
		}
		mu.Unlock()
	}
}
