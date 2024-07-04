/* USER CODE BEGIN Header */
/**
  ******************************************************************************
  * @file    subghz.h
  * @brief   This file contains all the function prototypes for
  *          the subghz.c file
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
/* Define to prevent recursive inclusion -------------------------------------*/
#ifndef __SUBGHZ_H__
#define __SUBGHZ_H__

#ifdef __cplusplus
extern "C" {
#endif

/* Includes ------------------------------------------------------------------*/
#include "main.h"

/* USER CODE BEGIN Includes */

/* USER CODE END Includes */

extern SUBGHZ_HandleTypeDef hsubghz;

/* USER CODE BEGIN Private defines */

typedef enum {
	RADIO_STANDBY_CLK_RC_13MHZ = 0,
	RADIO_STANDBY_CLK_HSE32 = 1,
} Radio_Standby_Clk_t;

typedef enum {
	RADIO_PACKET_TYPE_FSK = 0,
	RADIO_PACKET_TYPE_LORA,
	RADIO_PACKET_TYPE_BPSK,
	RADIO_PACKET_TYPE_MSK,
} Radio_Packet_Type_t;

typedef enum {
	RADIO_SPREADING_FACTOR_5 = 0x5,
	RADIO_SPREADING_FACTOR_6 = 0x6,
	RADIO_SPREADING_FACTOR_7 = 0x7,
	RADIO_SPREADING_FACTOR_8 = 0x8,
	RADIO_SPREADING_FACTOR_9 = 0x9,
	RADIO_SPREADING_FACTOR_10 = 0xA,
	RADIO_SPREADING_FACTOR_11 = 0xB,
	RADIO_SPREADING_FACTOR_12 = 0xC,
} Radio_Spreading_Factor_t;

typedef enum {
	RADIO_BANDWIDTH_7_81kHz = 0x00,
	RADIO_BANDWIDTH_10_42kHz = 0x08,
	RADIO_BANDWIDTH_15_63kHz = 0x01,
	RADIO_BANDWIDTH_20_83kHz = 0x09,
	RADIO_BANDWIDTH_31_25kHz = 0x02,
	RADIO_BANDWIDTH_41_67kHz = 0x0A,
	RADIO_BANDWIDTH_62_50kHz = 0x03,
	RADIO_BANDWIDTH_125kHz = 0x04,
	RADIO_BANDWIDTH_250kHz = 0x05,
	RADIO_BANDWIDTH_500kHz = 0x06,
} Radio_Bandwidth_t;

typedef enum {
	RADIO_ERR_CORREC_CODING_RATE_4_4 = 0x0,
	RADIO_ERR_CORREC_CODING_RATE_4_5 = 0x1,
	RADIO_ERR_CORREC_CODING_RATE_4_6 = 0x2,
	RADIO_ERR_CORREC_CODING_RATE_4_7 = 0x3,
	RADIO_ERR_CORREC_CODING_RATE_4_8 = 0x4,
} Radio_Error_Correction_Coding_Rate_t;

typedef enum {
	RADIO_LOW_DATA_RATE_OPT_DISABLED = 0x0,
	RADIO_LOW_DATA_RATE_OPT_ENABLED = 0x1,
} Radio_Low_Data_Rate_Optimization_t;

typedef enum {
	RADIO_HEADER_TYPE_EXPLICIT = 0x0,
	RADIO_HEADER_TYPE_IMPLICIT = 0x1,
} Radio_Header_Type_t;

typedef enum {
	RADIO_CRC_DISABLED = 0x0,
	RADIO_CRC_ENABLED = 0x1,
} Radio_CRC_Type_t;

typedef enum {
	RADIO_IQ_SETUP_STANDARD = 0x0,
	RADIO_IQ_SETUP_INVERTED = 0x1,
} Radio_IQ_Setup_t;

/* USER CODE END Private defines */

void MX_SUBGHZ_Init(void);

/* USER CODE BEGIN Prototypes */
HAL_StatusTypeDef Radio_Set_Standby(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Standby_Clk_t clk_conf);
HAL_StatusTypeDef Radio_Set_TX(SUBGHZ_HandleTypeDef* subghzHandle, uint32_t timeout);
HAL_StatusTypeDef Radio_Set_RX(SUBGHZ_HandleTypeDef* subghzHandle, uint32_t timeout);
HAL_StatusTypeDef Radio_Set_PacketType(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Packet_Type_t packet_type);
HAL_StatusTypeDef Radio_Set_ModulationParams(SUBGHZ_HandleTypeDef* subghzHandle, Radio_Spreading_Factor_t spreading_factor, Radio_Bandwidth_t bandwidth, Radio_Error_Correction_Coding_Rate_t coding_rate, Radio_Low_Data_Rate_Optimization_t ldro);
HAL_StatusTypeDef Radio_Set_PacketParams(SUBGHZ_HandleTypeDef* subghzHandle, uint16_t preamble_length, Radio_Header_Type_t header_type, uint8_t payload_length, Radio_CRC_Type_t crc, Radio_IQ_Setup_t invert_iq);
/* USER CODE END Prototypes */

#ifdef __cplusplus
}
#endif

#endif /* __SUBGHZ_H__ */

