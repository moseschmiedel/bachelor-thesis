/*
 * lora.c
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#include "lora.h"

#define STANDBY_CFG_STANDBY_CLK_RC_13MHZ 0

static uint8_t payload_length_g = 0;

HAL_StatusTypeDef LoRa_Init(uint16_t preamble_length, Radio_Header_Type_t header_type, uint8_t payload_length, Radio_CRC_Type_t crc, Radio_IQ_Setup_t iq_setup) {
	if (HAL_SUBGHZ_GetState(&hsubghz) == HAL_SUBGHZ_STATE_BUSY) {
		return HAL_BUSY;
	}

	if (Radio_Set_Standby(&hsubghz, RADIO_STANDBY_CLK_RC_13MHZ) == HAL_ERROR) {
		Error_Handler();
	}

	if (Radio_Set_RfFrequency(&hsubghz, LORA_BAND_P_BASE_FREQ) == HAL_ERROR) {
		Error_Handler();
	}

	if (Radio_Set_ModulationParams(&hsubghz, RADIO_SPREADING_FACTOR_7, RADIO_BANDWIDTH_125kHz, RADIO_ERR_CORREC_CODING_RATE_4_6, RADIO_LOW_DATA_RATE_OPT_DISABLED) == HAL_ERROR) {
		Error_Handler();
	}

	if (Radio_Set_PacketParams(&hsubghz, preamble_length, header_type, payload_length, crc, iq_setup) == HAL_ERROR) {
		Error_Handler();
	}

	payload_length_g = payload_length;

	return HAL_OK;
}

void LoRa_Send_Packet(uint8_t *payload) {
	if (HAL_SUBGHZ_WriteBuffer(&hsubghz, 0, payload, payload_length) == HAL_ERROR) {
		Error_Handler();
	}
	if (Radio_Set_TX(&hsubghz, 0) == HAL_ERROR) {
		Error_Handler();
	}
}
