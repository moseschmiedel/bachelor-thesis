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

HAL_StatusTypeDef LoRa_Send_Packet(uint8_t *payload) {
	if (HAL_SUBGHZ_GetState(&hsubghz) != HAL_SUBGHZ_STATE_READY) {
		return HAL_BUSY;
	}
	if (HAL_SUBGHZ_WriteBuffer(&hsubghz, 0, payload, payload_length_g) == HAL_ERROR) {
		Error_Handler();
	}
	if (Radio_Set_TX(&hsubghz, 0) == HAL_ERROR) {
		Error_Handler();
	}

	return HAL_OK;
}

static Future* rx_future_g;

void LoRa_Recv_Cplt_Callback(SUBGHZ_HandleTypeDef *subghzHandle) {
	if (rx_future_g == NULL) {
		return;
	}

	if (rx_future_g->buffer == NULL) {
		rx_future_g->state = FUTURE_ERROR;
		return;
	}

	if (HAL_SUBGHZ_ReadBuffer(subghzHandle, 0, rx_future_g->buffer, rx_future_g->size) == HAL_ERROR) {
		rx_future_g->state = FUTURE_ERROR;
		Error_Handler();
	}

	rx_future_g->state = FUTURE_SUCCESS;
}

void LoRa_Recv_Timeout_Callback(SUBGHZ_HandleTypeDef *subghzHandle) {
	if (rx_future_g == NULL) {
		return;
	}

	rx_future_g->state = FUTURE_ERROR;
}

void LoRa_Recv_Error_Callback(SUBGHZ_HandleTypeDef *subghzHandle) {
	if (rx_future_g == NULL) {
		return;
	}

	rx_future_g->state = FUTURE_ERROR;
}

HAL_StatusTypeDef LoRa_Recv_Packet(Future *future, uint8_t *buffer, uint32_t size) {
	if (HAL_SUBGHZ_GetState(&hsubghz) != HAL_SUBGHZ_STATE_READY) {
		future->state = FUTURE_WAITING;
		return HAL_BUSY;
	}

	hsubghz.RxCpltCallback = &LoRa_Recv_Cplt_Callback;
	hsubghz.RxTxTimeoutCallback = &LoRa_Recv_Timeout_Callback;
	hsubghz.HeaderErrorCallback = &LoRa_Recv_Error_Callback;
	hsubghz.CRCErrorCallback = &LoRa_Recv_Error_Callback;

	future->buffer = buffer;
	future->size = size;

	if (Radio_Set_RX(&hsubghz, 0) == HAL_ERROR) {
		Error_Handler();
	}

	future->state = FUTURE_WAITING;

	rx_future_g = future;

	return HAL_OK;
}
