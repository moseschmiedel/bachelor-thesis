/*
 * lora.c
 *
 *  Created on: Jun 30, 2024
 *      Author: mose
 */

#include "lora.h"

#define STANDBY_CFG_STANDBY_CLK_RC_13MHZ 0

static LoRaModem_t lora_modem_g = {
		.payload_length = 0,
		.state = LORA_MODEM_STBY,
};

LoRaModem_State_t LoRa_GetState() {
	return lora_modem_g.state;
}
void LoRa_ResetState() {
	lora_modem_g.state = LORA_MODEM_STBY;
}

void LoRa_CheckHealthAndReset() {
	Radio_Status_t radio_status;
	if (Radio_GetStatus(&hsubghz, &radio_status) != HAL_OK) {
		Error_Handler();
	}

	if (lora_modem_g.state != LORA_MODEM_STBY && (radio_status.mode == RADIO_STANDBY_RC13MHZ_MODE || radio_status.mode == RADIO_STANDBY_HSE32_MODE)) {
		LoRa_ResetState();
	}

}

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

	lora_modem_g.payload_length = payload_length;

	return HAL_OK;
}

void LoRa_Tx_Cplt_Callback(SUBGHZ_HandleTypeDef* subghzHandle) {
	lora_modem_g.state = LORA_MODEM_TX_CPLT;
}

void LoRa_Tx_Error_Callback(SUBGHZ_HandleTypeDef* subghzHandle) {
	lora_modem_g.state = LORA_MODEM_TX_ERROR;
}

void clr_interrupt_callbacks(SUBGHZ_HandleTypeDef* subghzHandle) {
//	subghzHandle->CADStatusCallback = NULL;
//	subghzHandle->CRCErrorCallback = NULL;
//	subghzHandle->HeaderErrorCallback = NULL;
//	subghzHandle->HeaderValidCallback = NULL;
//	subghzHandle->TxCpltCallback = NULL;
//	subghzHandle->RxCpltCallback = NULL;
//	subghzHandle->RxTxTimeoutCallback = NULL;
//	subghzHandle->LrFhssHopCallback = NULL;
//	subghzHandle->PreambleDetectedCallback = NULL;
//	subghzHandle->SyncWordValidCallback = NULL;
}

HAL_StatusTypeDef LoRa_Send_Packet(uint8_t *payload) {
	if (HAL_SUBGHZ_GetState(&hsubghz) != HAL_SUBGHZ_STATE_READY) {
		return HAL_BUSY;
	}

	if (Radio_Set_Standby(&hsubghz, RADIO_STANDBY_CLK_RC_13MHZ) != HAL_OK) {
		Error_Handler();
	}

	if (Radio_Set_BufferBaseAddress(&hsubghz, 0, 0) != HAL_OK) {
		Error_Handler();
	}

	if (HAL_SUBGHZ_WriteBuffer(&hsubghz, 0, payload, lora_modem_g.payload_length) != HAL_OK) {
		Error_Handler();
	}

	if (Radio_Set_PaConfig(&hsubghz, RADIO_PA_DUTY_1, RADIO_MAX_POWER_0, RADIO_LOW_POWER_PA) != HAL_OK) {
		Error_Handler();
	}

	if (Radio_Set_TxParams(&hsubghz, 0x0D, RADIO_RAMP_20us) != HAL_OK) {
		Error_Handler();
	}

	if (Radio_Cfg_DioIrq(&hsubghz, 0x1, 0x9, 0x0, 0x0) != HAL_OK) {
		Error_Handler();
	}

	//clr_interrupt_callbacks(&hsubghz);

	if (Radio_Set_TX(&hsubghz, 200) != HAL_OK) {
		Error_Handler();
	}

	lora_modem_g.state = LORA_MODEM_TX;

	return HAL_OK;
}

static Future* rx_future_g;

void LoRa_Rx_Cplt_Callback(SUBGHZ_HandleTypeDef* subghzHandle) {
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

void LoRa_Rx_Error_Callback(SUBGHZ_HandleTypeDef* subghzHandle) {
	if (rx_future_g == NULL) {
		return;
	}

	Radio_RX_Buffer_Status_t rx_status = Radio_Get_RxBufferStatus(subghzHandle);

	char str[70];
	sprintf(str, "[RX] Status: mode: %u, cmd-status: %u", rx_status.mode, rx_status.command_status);
	dbg_printf(str);

	rx_future_g->state = FUTURE_ERROR;
}


HAL_StatusTypeDef LoRa_Recv_Packet(Future *future, uint8_t *buffer, uint32_t size) {
	if (HAL_SUBGHZ_GetState(&hsubghz) != HAL_SUBGHZ_STATE_READY) {
		future->state = FUTURE_WAITING;
		return HAL_BUSY;
	}

	//clr_interrupt_callbacks(&hsubghz);

	future->buffer = buffer;
	future->size = size;

	future->state = FUTURE_WAITING;
	rx_future_g = future;

	if (Radio_Set_RX(&hsubghz, 2000) == HAL_ERROR) {
		Error_Handler();
	}

	return HAL_OK;
}

void LoRa_print_debug_tx() {
	Radio_Status_t radio_status;
	if (Radio_GetStatus(&hsubghz, &radio_status) != HAL_OK) {
		Error_Handler();
	}
	BEGIN_CRITICAL_SECTION();
	char str[70];
	sprintf(str, "mode: %u, cmd_status: %u\n", radio_status.mode, radio_status.command_status);
	EXIT_CRITICAL_SECTION();

	dbg_printf(str);
}
