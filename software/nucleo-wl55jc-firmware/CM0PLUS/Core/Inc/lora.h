/*
 * lora.h
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#ifndef INC_LORA_H_
#define INC_LORA_H_

#include "main.h"
#include "subghz.h"
#include "utils.h"

#include <stdint.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>

#define LORA_BAND_K_BASE_FREQ (863000000UL)
#define LORA_BAND_L_BASE_FREQ (865000000UL)
#define LORA_BAND_M_BASE_FREQ (868000000UL)
#define LORA_BAND_N_BASE_FREQ (868700000UL)
#define LORA_BAND_P_BASE_FREQ (869400000UL)
#define LORA_BAND_Q_BASE_FREQ (869700000UL)

#define LORA_BAND_K_BANDWIDTH (2000000UL)
#define LORA_BAND_L_BANDWIDTH (3000000UL)
#define LORA_BAND_M_BANDWIDTH (600000U)
#define LORA_BAND_N_BANDWIDTH (500000U)
#define LORA_BAND_P_BANDWIDTH (250000U)
#define LORA_BAND_Q_BANDWIDTH (300000U)

typedef enum {
	LORA_MODEM_STBY = 0x0,
	LORA_MODEM_TX,
	LORA_MODEM_TX_CPLT,
	LORA_MODEM_TX_ERROR,
	LORA_MODEM_RX,
	LORA_MODEM_RX_CPLT,
	LORA_MODEM_RX_ERROR,
} LoRaModem_State_t;

typedef struct {
	uint8_t payload_length;
	LoRaModem_State_t state;
} LoRaModem_t;

LoRaModem_State_t LoRa_GetState();
void LoRa_ResetState();
void LoRa_CheckHealthAndReset();

HAL_StatusTypeDef LoRa_Init(uint16_t preamble_length, Radio_Header_Type_t header_type, uint8_t payload_length, Radio_CRC_Type_t crc, Radio_IQ_Setup_t iq_setup);
HAL_StatusTypeDef LoRa_Send_Packet(uint8_t *payload);
HAL_StatusTypeDef LoRa_Recv_Packet(Future* future, uint8_t *buffer, uint32_t size);

void LoRa_print_debug_tx();

#endif /* INC_LORA_H_ */
