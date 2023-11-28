#include "classify_chars.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


void classify_chars_in_string(char* string, char** vowels_and_cons) {
	if(string == NUL || *string == '\0') {
		return;
	} else {
		while(string != 0) {
			
		}
	}
}

void classify_chars(classifier_t* array, uint64_t size_of_array) {
	char* vowels = calloc(65, sizeof(char));
	char* consonants = calloc(65, sizeof(char));
	char** vowels_and_consonants = malloc(2 * sizeof(consonants));
	vowels_and_consonants[0] = vowels;
	vowels_and_consonants[1] = consonants;
	for(uint64_t i = 0; i < size_of_array; i++) {
		classify_chars_in_string(array[i], vowels_and_consonants);
	}
}
