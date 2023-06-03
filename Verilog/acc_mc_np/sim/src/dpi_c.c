#include <stdlib.h>

DPI int get_env_var(const char* name, char* value) {
  char* var = getenv(name);
  if (var == NULL) {
    return 0;
  }
  strcpy(value, var);
  return 1;
}