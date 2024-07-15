/*
 * lora_locator.c
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#include "lora_locator.h"

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

void LoRa_Locator_Init() {
	app_state.packets_gw_a = init_list();
	app_state.packets_gw_b = init_list();
	app_state.packets_gw_c = init_list();
}

ProcessState_t LoRa_Locator_Run() {
	// check lora rx/tx window
	// -> recv / trans lora packet
	// calculate position with three last gateway packets
	// -> store position in positions table
	// -> queue position for transmission via lora
	ProcessState_t state;
	state.code = PROCESS_OK;
	return state;
}
