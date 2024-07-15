/*
 * lora_locator.c
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#include "Apps/lora_locator.h"

#define LIST_CAPACITY 10

typedef struct {
	LoRaLocatorPacket buffer[LIST_CAPACITY];
	uint32_t len;
} LoRaLocatorPacketCircularList;

LoRaLocatorPacketCircularList init_list() {
	LoRaLocatorPacketCircularList list;
	list.len = 0;
	return list;
}

void list_append(LoRaLocatorPacketCircularList *list, LoRaLocatorPacket packet) {
	if (list->len >= LIST_CAPACITY) {
		list->len = 0;
	}

	list->buffer[list->len] = packet;
}

typedef struct {
	LoRaLocatorPacketCircularList packets_gw_a;
	LoRaLocatorPacketCircularList packets_gw_b;
	LoRaLocatorPacketCircularList packets_gw_c;
	uint32_t positions[10];
} LoRaLocatorState_t;

static LoRaLocatorState_t app_state;

void LoRa_Locator_Configure_LoRa_Modem() {
  LoRa_Init(12, RADIO_HEADER_TYPE_IMPLICIT, sizeof(LoRaLocatorPacket), RADIO_CRC_ENABLED, RADIO_IQ_SETUP_STANDARD);
}

static LoRaLocatorDeviceType lora_locator_device_type_g = LORA_LOCATOR_UNDEF_DEVICE;

void LoRa_Locator_Init(LoRaLocatorDeviceType device_type) {
	app_state.packets_gw_a = init_list();
	app_state.packets_gw_b = init_list();
	app_state.packets_gw_c = init_list();
	lora_locator_device_type_g = device_type;
}

/**
 * @param buf_out Buffer must have minimum size of `sizeof(LoRaLocatorPacket)`
 */
void write_packet_buffer(uint8_t *buf_out, LoRaLocatorPacket packet) {
	buf_out[0] = packet.type;
	buf_out[1] = (uint8_t) (packet.timestamp >> 24) & 0xFF;
	buf_out[2] = (uint8_t) (packet.timestamp >> 16) & 0xFF;
	buf_out[3] = (uint8_t) (packet.timestamp >> 8) & 0xFF;
	buf_out[4] = (uint8_t) (packet.timestamp >> 0) & 0xFF;
}

/**
 * @param buf_out Buffer must have minimum size of `sizeof(LoRaLocatorPacket)`
 */
LoRaLocatorPacket packet_from_packet_buffer(uint8_t *buf_out) {
	LoRaLocatorPacket packet;
	packet.type = buf_out[0];
	packet.timestamp = buf_out[1] << 24;
	packet.timestamp |= buf_out[2] << 16;
	packet.timestamp |= buf_out[3] << 8;
	packet.timestamp |= buf_out[4];

	return packet;
}

static ProcessState_t process_state_g;
ProcessState_t LoRa_Locator_Run() {
	// check lora rx/tx window
	// -> recv / trans lora packet
	// calculate position with three last gateway packets
	// -> store position in positions table
	// -> queue position for transmission via lora
	process_state_g.code = PROCESS_OK;

	uint8_t packet_buf[sizeof(LoRaLocatorPacket)];

	switch (lora_locator_device_type_g) {
	case LORA_LOCATOR_UNDEF_DEVICE: {
		dbg_printf("`device_type_g` is uninitialized. Maybe you forgot to set the device type when calling `LoRaLocatorInit()`\n");
	} break;
	case LORA_LOCATOR_BEACON: {
		LoRaLocatorPacket packet;
		packet.type = LORA_LOC_TIMESTAMP;
		packet.timestamp = 42;

		write_packet_buffer(packet_buf, packet);

		if (LoRa_Send_Packet(packet_buf) == HAL_BUSY) {
			dbg_printf("Retry transmit.\n");
		} else {
			dbg_printf("Sent LoRaLocatorPacket!\n");
		}
	} break;
	case LORA_LOCATOR_TAG: {
		Future future = init_future();
		if (LoRa_Recv_Packet(&future, packet_buf, sizeof(LoRaLocatorPacket)) != HAL_OK) {
			dbg_printf("[RX] Retry receive.\n");
			return process_state_g;
		}
		future_await(&future);
		if (future.state == FUTURE_ERROR) {
			dbg_printf("[RX] Error\n");
		} else {
			dbg_printf("[RX] Received LoRaLocatorPacket!\n");
			LoRaLocatorPacket packet = packet_from_packet_buffer(future.buffer);
			char dbg_str[70];
			sprintf(dbg_str, "[RX] packet type: %u timestamp/location: %lu\n", packet.type, packet.timestamp);
			dbg_printf(dbg_str);
		}
	} break;
	}

	return process_state_g;
}
