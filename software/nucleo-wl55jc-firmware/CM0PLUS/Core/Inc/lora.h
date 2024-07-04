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

HAL_StatusTypeDef LoRa_Init(uint16_t preamble_length, Radio_Header_Type_t header_type, uint8_t payload_length, Radio_CRC_Type_t crc, Radio_IQ_Setup_t iq_setup);


#endif /* INC_LORA_H_ */
