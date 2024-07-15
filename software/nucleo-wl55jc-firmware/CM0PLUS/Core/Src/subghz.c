/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    subghz.c
  * @brief   This file provides code for the configuration
  *          of the SUBGHZ instances.
  ******************************************************************************
  * @attention
  *
  * Copyright (c) 2024 STMicroelectronics.
  * All rights reserved.
  *
  * This software is licensed under terms that can be found in the LICENSE file
  * in the root directory of this software component.
  * If no LICENSE file comes with this software, it is provided AS-IS.
  *
  ******************************************************************************
  */
/* USER CODE END Header */
/* Includes ------------------------------------------------------------------*/
#include "subghz.h"

/* USER CODE BEGIN 0 */

/* USER CODE END 0 */

SUBGHZ_HandleTypeDef hsubghz;

/* SUBGHZ init function */
void MX_SUBGHZ_Init(void)
{

  /* USER CODE BEGIN SUBGHZ_Init 0 */

  /* USER CODE END SUBGHZ_Init 0 */

  /* USER CODE BEGIN SUBGHZ_Init 1 */

  /* USER CODE END SUBGHZ_Init 1 */
  hsubghz.Init.BaudratePrescaler = SUBGHZSPI_BAUDRATEPRESCALER_8;
  if (HAL_SUBGHZ_Init(&hsubghz) != HAL_OK)
  {
    Error_Handler();
  }
  /* USER CODE BEGIN SUBGHZ_Init 2 */

  /* USER CODE END SUBGHZ_Init 2 */

}

void HAL_SUBGHZ_MspInit(SUBGHZ_HandleTypeDef* subghzHandle)
{

  /* USER CODE BEGIN SUBGHZ_MspInit 0 */

  /* USER CODE END SUBGHZ_MspInit 0 */
    /* SUBGHZ clock enable */
    __HAL_RCC_SUBGHZSPI_CLK_ENABLE();

    /* SUBGHZ interrupt Init */
    HAL_NVIC_SetPriority(SUBGHZ_Radio_IRQn, 0, 0);
    HAL_NVIC_EnableIRQ(SUBGHZ_Radio_IRQn);
  /* USER CODE BEGIN SUBGHZ_MspInit 1 */

  /* USER CODE END SUBGHZ_MspInit 1 */
}

void HAL_SUBGHZ_MspDeInit(SUBGHZ_HandleTypeDef* subghzHandle)
{

  /* USER CODE BEGIN SUBGHZ_MspDeInit 0 */

  /* USER CODE END SUBGHZ_MspDeInit 0 */
    /* Peripheral clock disable */
    __HAL_RCC_SUBGHZSPI_CLK_DISABLE();

    /* SUBGHZ interrupt Deinit */
    HAL_NVIC_DisableIRQ(SUBGHZ_Radio_IRQn);
  /* USER CODE BEGIN SUBGHZ_MspDeInit 1 */

  /* USER CODE END SUBGHZ_MspDeInit 1 */
}

/* USER CODE BEGIN 1 */
HAL_StatusTypeDef Radio_Set_Standby(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Standby_Clk_t clk_conf) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 1
	uint8_t cmd_data[CMD_DATA_SIZE] = {clk_conf};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_STANDBY, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Set_TX(SUBGHZ_HandleTypeDef* subghzHandle, uint32_t timeout) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 3
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			(uint8_t) (timeout >> 16),
			(uint8_t) (timeout >> 8),
			(uint8_t) (timeout),
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_TX, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Set_RX(SUBGHZ_HandleTypeDef* subghzHandle, uint32_t timeout) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 3
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			(uint8_t) (timeout >> 16),
			(uint8_t) (timeout >> 8),
			(uint8_t) (timeout),
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_RX, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Set_PacketType(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Packet_Type_t packet_type) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 1
	uint8_t cmd_data[CMD_DATA_SIZE] = {packet_type};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_PACKETTYPE, cmd_data, CMD_DATA_SIZE);
}

#define XTAL_FREQ ( 32000000UL )

#define FREQ_TO_RF_PLL_FREQ( rf_pll, freq )                                  \
do                                                                           \
{                                                                            \
  rf_pll = (uint32_t) ((((uint64_t) freq)<<25)/(XTAL_FREQ) );               \
}while( 0 )

HAL_StatusTypeDef Radio_Set_RfFrequency(SUBGHZ_HandleTypeDef* subghzHandle, uint32_t freq) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 4
	// calculate
	uint32_t rf_pll_freq = 0;
	FREQ_TO_RF_PLL_FREQ(rf_pll_freq, freq);
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			(uint8_t) rf_pll_freq >> 24 && 0xFF,
			(uint8_t) rf_pll_freq >> 16 && 0xFF,
			(uint8_t) rf_pll_freq >> 8 && 0xFF,
			(uint8_t) rf_pll_freq && 0xFF,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_RFFREQUENCY, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Set_ModulationParams(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Spreading_Factor_t spreading_factor, Radio_Bandwidth_t bandwidth, Radio_Error_Correction_Coding_Rate_t coding_rate, Radio_Low_Data_Rate_Optimization_t ldro) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 4
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			spreading_factor,
			bandwidth,
			coding_rate,
			ldro,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_MODULATIONPARAMS, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Set_PacketParams(SUBGHZ_HandleTypeDef* subghzHandle, uint16_t preamble_length, Radio_Header_Type_t header_type, uint8_t payload_length, Radio_CRC_Type_t crc, Radio_IQ_Setup_t iq_setup) {
	if (preamble_length == 0) {
		// value 0x00 is reserved for PbLength (preamble_length)
		return HAL_ERROR;
	}

	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 6
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			(uint8_t) (preamble_length >> 8),
			(uint8_t) (preamble_length),
			header_type,
			payload_length,
			crc,
			iq_setup,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_PACKETPARAMS, cmd_data, CMD_DATA_SIZE);
}

/**
 * Indicates error of the SPI Get command by setting `command_status` to `RADIO_GET_CMD_ERROR` in return struct
 */
Radio_RxBufferStatus_t Radio_Get_RxBufferStatus(SUBGHZ_HandleTypeDef* subghzHandle) {
	Radio_RxBufferStatus_t buffer_status;

#undef CMD_DATA_SIZE
#define CMD_DATA_SIZE 3
	uint8_t cmd_data[CMD_DATA_SIZE];
	if (HAL_SUBGHZ_ExecGetCmd(&hsubghz, RADIO_GET_RXBUFFERSTATUS, cmd_data, CMD_DATA_SIZE) != HAL_OK) {
		buffer_status.command_status = RADIO_GET_CMD_ERROR;
		return buffer_status;
	}

	buffer_status.mode = cmd_data[0] >> 4 && 0xFF;
	buffer_status.command_status = cmd_data[0] >> 1 && 0xFF;
	buffer_status.rx_payload_length = cmd_data[1];
	buffer_status.rx_buffer_pointer = cmd_data[2];

	return buffer_status;
}

/* USER CODE END 1 */
