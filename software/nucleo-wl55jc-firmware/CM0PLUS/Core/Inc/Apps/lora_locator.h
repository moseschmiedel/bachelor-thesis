/*
 * lora_locator.h
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#ifndef LORALOCATOR_LORA_LOCATOR_H_
#define LORALOCATOR_LORA_LOCATOR_H_

#include <stdint.h>

#include "process.h"

/** Packet structure used by the LoRa Geolocation App
 *
 */
typedef struct {
	uint8_t type;
	union {
		uint32_t timestamp;
		uint32_t location;
	};
} LoRaLocatorPacket;

void LoRa_Locator_Init();
ProcessState_t LoRa_Locator_Run();

#endif /* LORALOCATOR_LORA_LOCATOR_H_ */
