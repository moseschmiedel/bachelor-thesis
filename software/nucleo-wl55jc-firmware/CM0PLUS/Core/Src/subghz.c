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
HAL_StatusTypeDef Radio_Set_Payload(SUBGHZ_HandleTypeDef* subghzHandle, uint8_t offset, uint8_t* payload, uint8_t size) {
	BEGIN_CRITICAL_SECTION();

	HAL_SUBGHZ_WriteBuffer(subghzHandle, offset, payload, size);

	EXIT_CRITICAL_SECTION();
}
HAL_StatusTypeDef Radio_Set_Standby(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Standby_Clk_t clk_conf) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 1
	uint8_t cmd_data[CMD_DATA_SIZE] = {clk_conf};
	BEGIN_CRITICAL_SECTION();
	HAL_StatusTypeDef result = HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_STANDBY, cmd_data, CMD_DATA_SIZE);
	EXIT_CRITICAL_SECTION();
	return result;
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

HAL_StatusTypeDef Radio_Set_BufferBaseAddress(SUBGHZ_HandleTypeDef* subghzHandle, uint8_t tx_baseaddr, uint8_t rx_baseaddr) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 2
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			tx_baseaddr,
			rx_baseaddr,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_BUFFERBASEADDRESS, cmd_data, CMD_DATA_SIZE);
}

/***************************
 * Interrupt configuration *
 ***************************/

HAL_StatusTypeDef Radio_Cfg_DioIrq(SUBGHZ_HandleTypeDef* subghzHandle, uint16_t irq0mask, uint16_t irq1mask, uint16_t irq2mask, uint16_t irq3mask) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 8
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			(uint8_t) (irq0mask >> 8) & 0xFF,
			(uint8_t) (irq0mask >> 0) & 0xFF,
			(uint8_t) (irq1mask >> 8) & 0xFF,
			(uint8_t) (irq1mask >> 0) & 0xFF,
			(uint8_t) (irq2mask >> 8) & 0xFF,
			(uint8_t) (irq2mask >> 0) & 0xFF,
			(uint8_t) (irq3mask >> 8) & 0xFF,
			(uint8_t) (irq3mask >> 0) & 0xFF,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_CFG_DIOIRQ, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Get_IrqStatus(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Irq_Status_t* irq_status) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 3
	uint8_t cmd_data[CMD_DATA_SIZE];
	HAL_StatusTypeDef result;
	if ((result = HAL_SUBGHZ_ExecGetCmd(subghzHandle, RADIO_GET_IRQSTATUS, cmd_data, CMD_DATA_SIZE)) != HAL_OK) {
		return result;
	}

	return HAL_OK;
}

HAL_StatusTypeDef Radio_Clr_IrqStatus(SUBGHZ_HandleTypeDef* subghzHandle, uint16_t irq_clear_mask) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 2
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			(uint8_t) (irq_clear_mask >> 8) & 0xFF,
			(uint8_t) (irq_clear_mask >> 0) & 0xFF,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_CLR_IRQSTATUS, cmd_data, CMD_DATA_SIZE);
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
			(uint8_t) rf_pll_freq >> 24 & 0xFF,
			(uint8_t) rf_pll_freq >> 16 & 0xFF,
			(uint8_t) rf_pll_freq >> 8 & 0xFF,
			(uint8_t) rf_pll_freq & 0xFF,
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

HAL_StatusTypeDef Radio_Set_PaConfig(SUBGHZ_HandleTypeDef* subghzHandle, Radio_PA_Duty_Cycle_t duty_cycle, Radio_Max_Power_t max_power, Radio_PA_Sel_t pa_sel) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 4
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			duty_cycle,
			max_power,
			pa_sel,
			0x1,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_PACONFIG, cmd_data, CMD_DATA_SIZE);
}

HAL_StatusTypeDef Radio_Set_TxParams(SUBGHZ_HandleTypeDef* subghzHandle, Radio_TX_Power_t power, Radio_Ramp_Time_t ramp_time) {
	#undef CMD_DATA_SIZE
	#define CMD_DATA_SIZE 2
	uint8_t cmd_data[CMD_DATA_SIZE] = {
			power,
			ramp_time,
	};
	return HAL_SUBGHZ_ExecSetCmd(subghzHandle, RADIO_SET_TXPARAMS, cmd_data, CMD_DATA_SIZE);
}

/**
 * Indicates error of the SPI Get command by setting `command_status` to `RADIO_GET_CMD_ERROR` in return struct
 */
Radio_RX_Buffer_Status_t Radio_Get_RxBufferStatus(SUBGHZ_HandleTypeDef* subghzHandle) {
	Radio_RX_Buffer_Status_t buffer_status;

#undef CMD_DATA_SIZE
#define CMD_DATA_SIZE 3
	uint8_t cmd_data[CMD_DATA_SIZE];
	if (HAL_SUBGHZ_ExecGetCmd(&hsubghz, RADIO_GET_RXBUFFERSTATUS, cmd_data, CMD_DATA_SIZE) != HAL_OK) {
		buffer_status.command_status = RADIO_GET_CMD_ERROR;
		return buffer_status;
	}

	buffer_status.mode = cmd_data[0] >> 4 & 0xFF;
	buffer_status.command_status = cmd_data[0] >> 1 & 0xFF;
	buffer_status.rx_payload_length = cmd_data[1];
	buffer_status.rx_buffer_pointer = cmd_data[2];

	return buffer_status;
}

HAL_StatusTypeDef Radio_GetStatus(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Status_t* status) {
#undef CMD_DATA_SIZE
#define CMD_DATA_SIZE 1
	uint8_t cmd_data[CMD_DATA_SIZE];
	HAL_StatusTypeDef result;
	if ((result = HAL_SUBGHZ_ExecGetCmd(&hsubghz, RADIO_GET_STATUS, cmd_data, CMD_DATA_SIZE)) != HAL_OK) {
		return result;
	}

	status->mode = cmd_data[0] >> 4 & 0x7;
	status->command_status = cmd_data[0] >> 1 & 0x7;

	return HAL_OK;
}

/**********************
 * Interrupt Handlers *
 **********************/

void HAL_SUBGHZ_TxCpltCallback(SUBGHZ_HandleTypeDef* subghzHandle) {
	dbg_printf("TX Complete\n");
}
void HAL_SUBGHZ_RxCpltCallback(SUBGHZ_HandleTypeDef* subghzHandle) {
	dbg_printf("RX Complete\n");
}
void HAL_SUBGHZ_RxTxTimeoutCallback(SUBGHZ_HandleTypeDef* subghzHandle) {
	dbg_printf("RX/TX Timeout\n");
}

/* USER CODE END 1 */
