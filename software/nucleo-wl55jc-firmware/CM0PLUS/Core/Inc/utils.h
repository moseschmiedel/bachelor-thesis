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


#define BEGIN_CRITICAL_SECTION() uint32_t __primask = __get_PRIMASK(); __disable_irq()
#define EXIT_CRITICAL_SECTION() __set_PRIMASK(__primask)



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
void run_printer();

Future init_future();
void future_await(Future* future);

#endif /* INC_UTILS_H_ */
