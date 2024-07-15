/*
 * utils.h
 *
 *  Created on: Jul 15, 2024
 *      Author: mschmiedel
 */

#ifndef INC_UTILS_H_
#define INC_UTILS_H_

#include <stdarg.h>
#include <string.h>

#include "usart.h"

typedef enum {
	FUTURE_WAITING = 0,
	FUTURE_SUCCESS = 1,
	FUTURE_ERROR = 2,
} FutureState;

typedef struct {
	uint8_t *buffer;
	uint32_t size;
	FutureState state;
} Future;

/**
 * Does not yet implement format functionality.
 */
int dbg_printf(char* str);

Future init_future();
void future_await(Future* future);

#endif /* INC_UTILS_H_ */
