#include "utils.h"

#define PRINT_QUEUE_MAX_SIZE 20

// id == 0 && payload == NULL && size == 0 indicate empty PrintQueueElem_t
typedef struct {
	uint32_t id;
	uint8_t* payload;
	uint16_t size;
} PrintQueueElem_t;

static PrintQueueElem_t print_queue[PRINT_QUEUE_MAX_SIZE];
static uint8_t print_queue_no_elems = 0;
static uint8_t print_queue_start_idx = 0;
static uint8_t print_queue_end_idx = 0;
static uint32_t print_queue_id_gen = 0;

uint8_t print_queue_len() {
	return print_queue_no_elems;
}

void print_queue_append(uint8_t* payload, uint16_t size) {
	if (print_queue_end_idx >= PRINT_QUEUE_MAX_SIZE) {
		if (print_queue_start_idx <= 0) {
			return; // queue is full
		}
		print_queue_end_idx = 0;
	}

	// append new queue element
	print_queue[print_queue_end_idx].id = print_queue_id_gen;
	print_queue[print_queue_end_idx].payload = payload;
	print_queue[print_queue_end_idx].size = size;

	// increase id and end_idx
	print_queue_id_gen++;
	print_queue_end_idx++;
	print_queue_no_elems++;
}

PrintQueueElem_t print_queue_pop() {
	PrintQueueElem_t result;
	if (print_queue_no_elems == 0) {
		result.id = 0;
		result.payload = NULL;
		result.size = 0;
		return; // empty queue
	}

	// copy queue element
	result = print_queue[print_queue_start_idx];

	// clear queue element
	print_queue[print_queue_start_idx].id = 0;
	print_queue[print_queue_start_idx].payload = NULL;
	print_queue[print_queue_start_idx].size = 0;

	print_queue_start_idx++;
	if (print_queue_start_idx >= PRINT_QUEUE_MAX_SIZE) {
		print_queue_start_idx = 0;
	}

	print_queue_no_elems--;

	return result;
}

static uint8_t print_semaphore = 1;
void acquire_print_lock() {
	while (print_semaphore <= 0) {
	}

	print_semaphore--;
}

void release_print_lock() {
	print_semaphore++;
}

int dbg_printf(char* str) {
	acquire_print_lock();

	uint32_t length = strlen(str);
	print_queue_append(str, length);

	release_print_lock();

	return length;
}

void run_printer() {
	if (print_queue_len() == 0) {
		return;
	}
	if (!UART_get_TC(&huart2)) {
		return;
	}


	PrintQueueElem_t elem = print_queue_pop();

	if (UART_Print_String(&huart2, elem.payload, elem.size) != HAL_OK) {
		Error_Handler();
	}
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
