package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"
	"sync"
	"time"

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
	heartbeats   = make(map[string]*time.Timer)
)

const heartbeatTimeout = 5 * time.Minute

func initLog() {
	file, err := os.OpenFile("app.log", os.O_CREATE|os.O_APPEND|os.O_WRONLY, 0666)
	if err != nil {
		log.Fatalf("failed to open log file: %v", err)
	}
	log.SetOutput(file)
	log.SetFlags(log.Ldate | log.Ltime | log.Lshortfile)
}

func main() {
	initLog()
	router := gin.Default()

	router.POST("/events", handleEvents)
	router.POST("/message/push", handleMessage)
	router.POST("/heartbeat", handleHeartbeat)

	go processMessages()

	router.Run(":8000")
}

func handleEvents(c *gin.Context) {
	var request struct {
		ApiKey string `json:"apikey" binding:"required"`
	}

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid JSON"})
		return
	}

	apikey := request.ApiKey

	closeClient(apikey)
	mu.Lock()
	var messageChan = make(chan Message)
	clients[apikey] = messageChan
	mu.Unlock()

	resetHeartbeat(apikey)

	// defer func() {
	// 	closeClient(apikey)
	// }()

	c.Header("Content-Type", "text/event-stream")
	c.Header("Cache-Control", "no-cache")
	c.Header("Connection", "keep-alive")

	flusher, ok := c.Writer.(http.Flusher)
	if !ok {
		http.Error(c.Writer, "Streaming unsupported!", http.StatusInternalServerError)
		return
	}
	log.Printf("client [%s] is listening...", apikey)

	reply := "connected"
	fmt.Fprintf(c.Writer, "data: %s\n\n", reply)
	flusher.Flush()

	for {
		select {
		case message, ok := <-messageChan:
			// log.Println("received data, will push to client")
			if !ok {
				return
			}
			messageJSON, err := json.Marshal(message)
			if err != nil {
				log.Println("Error marshaling message:", err)
				continue
			}
			fmt.Fprintf(c.Writer, "data: %s\n\n", messageJSON)
			flusher.Flush()
		}
	}
}

func handleMessage(c *gin.Context) {
	var msg Message
	if err := c.ShouldBindJSON(&msg); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	messageQueue <- msg
	c.JSON(http.StatusOK, gin.H{"status": "Success"})
}

func handleHeartbeat(c *gin.Context) {
	var request struct {
		ApiKey string `json:"apikey" binding:"required"`
	}
	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Invalid request"})
		return
	}

	apikey := request.ApiKey
	mu.Lock()
	defer mu.Unlock()
	if _, exists := clients[apikey]; exists {
		resetHeartbeat(apikey)
		c.JSON(http.StatusOK, gin.H{"status": "Heartbeat received"})
	} else {
		c.JSON(http.StatusNotFound, gin.H{"error": "Client not found"})
	}
}

func processMessages() {
	for {
		msg := <-messageQueue
		mu.Lock()
		if clientChan, exists := clients[msg.ApiKey]; exists {
			clientChan <- msg
		} else {
			log.Println("No clients for API key:", msg.ApiKey)
		}
		mu.Unlock()
	}
}

func resetHeartbeat(apikey string) {
	if timer, exists := heartbeats[apikey]; exists {
		timer.Stop()
	}
	heartbeats[apikey] = time.AfterFunc(heartbeatTimeout, func() {
		closeClient(apikey)
	})
}

func closeClient(apikey string) {
	mu.Lock()
	if ch, exists := clients[apikey]; exists {
		close(ch)
		delete(clients, apikey)
	}
	if timer, exists := heartbeats[apikey]; exists {
		timer.Stop()
		delete(heartbeats, apikey)
	}
	log.Println("disconnect client: ", apikey)
	mu.Unlock()
}
