// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<Settings> {
  @override
  final int typeId = 1;

  @override
  Settings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settings(
      language: fields[0] as String,
      autoStartup: fields[1] as bool,
      hiddenStartup: fields[2] as bool,
      quitToTray: fields[3] as bool,
      customServer: fields[4] as bool,
      serverHost: fields[5] as String,
      serverPort: fields[6] as String,
      enableSSL: fields[7] as bool,
      apiKey: fields[8] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Settings obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.language)
      ..writeByte(1)
      ..write(obj.autoStartup)
      ..writeByte(2)
      ..write(obj.hiddenStartup)
      ..writeByte(3)
      ..write(obj.quitToTray)
      ..writeByte(4)
      ..write(obj.customServer)
      ..writeByte(5)
      ..write(obj.serverHost)
      ..writeByte(6)
      ..write(obj.serverPort)
      ..writeByte(7)
      ..write(obj.enableSSL)
      ..writeByte(8)
      ..write(obj.apiKey);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
