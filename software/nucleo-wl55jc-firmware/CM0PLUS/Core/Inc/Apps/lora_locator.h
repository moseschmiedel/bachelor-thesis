/*
 * lora_locator.h
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#ifndef LORALOCATOR_LORA_LOCATOR_H_
#define LORALOCATOR_LORA_LOCATOR_H_

#include <stdint.h>
#include <stdio.h>

#include "Apps/process.h"

#include "lora.h"
#include "utils.h"

typedef enum {
	LORA_LOC_TIMESTAMP = 0,
	LORA_LOC_LOCATION,
} LoRaLocatorPacketType_t;

#define LoRaLocatorPacketType uint8_t

/** Packet structure used by the LoRa Geolocation App
 *
 */
typedef struct {
	LoRaLocatorPacketType type;
	union {
		uint32_t timestamp;
		uint32_t location;
	};
} LoRaLocatorPacket;

typedef enum {
	LORA_LOCATOR_UNDEF_DEVICE = 0,
	LORA_LOCATOR_BEACON,
	LORA_LOCATOR_TAG,
} LoRaLocatorDeviceType;

void LoRa_Locator_Configure_LoRa_Modem();
void LoRa_Locator_Init(LoRaLocatorDeviceType device_type);
ProcessState_t LoRa_Locator_Run();

#endif /* LORALOCATOR_LORA_LOCATOR_H_ */
