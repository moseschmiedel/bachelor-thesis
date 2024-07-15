#include "utils.h"

int dbg_printf(char* str) {
	uint32_t length = strlen(str);

	HAL_StatusTypeDef result = HAL_OK;
	do {
		result = UART_Print_String(&huart2, str, length);

		if (result == HAL_OK) {
			return length;
		}
	} while (result != HAL_OK);
}

Future init_future() {
	Future future;
	future.buffer = NULL;
	future.size = 0;
	future.state = FUTURE_WAITING;
	return future;
}

void future_await(Future* future) {
	dbg_printf("start of await\n");
	while (future->state == FUTURE_WAITING) {
	};
	dbg_printf("end of await\n");
}
