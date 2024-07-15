/*
 * process.h
 *
 *  Created on: Jul 1, 2024
 *      Author: mose
 */

#ifndef PROCESS_H_
#define PROCESS_H_

typedef enum {
	PROCESS_OK = 0,
	PROCESS_ERROR = 1,
} ProcessCode_t;

typedef struct {
	ProcessCode_t code;
} ProcessState_t;

void ProcessError();

#endif /* PROCESS_H_ */
