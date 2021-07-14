#include <unistd.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include "libpressio.h"
#include "libpressio_ext/json/pressio_options_json.h"

char* read_file(const char* filepath) {
  int json_fd = open(filepath, O_RDONLY);

  if(json_fd == -1) {
    perror("failed to open json file");
    exit(1);
  }

  struct stat json_stat;
  if(fstat(json_fd, &json_stat)) {
    perror("failed to get file size");
    close(json_fd);
    exit(1);
  }

  char * json_str = malloc(json_stat.st_size + 1);
  if(json_str == NULL) {
    perror("insufficient memory");
    close(json_fd);
    exit(1);
  }

  size_t current = 0;
  ssize_t read_bytes = 0;
  while ((read_bytes = read(json_fd, json_str+current, json_stat.st_size - current)) > 0) {
    current += read_bytes;
  }
  json_str[current] = '\0';

  if (read_bytes == -1) {
    perror("failed to read file");
    close(json_fd);
    free(json_str);
    exit(1);
  }

  return json_str;
}

int main(int argc, char *argv[])
{
  if(argc != 2) {
    fprintf(stderr, "./pressio_json json_file\n");
    exit(1);
  }
  char* json_str = read_file(argv[1]);

  struct pressio* library = pressio_instance();
  struct pressio_options* json_options = pressio_options_new_json(library, json_str);

  if(json_options == NULL) {
    int ec = pressio_error_code(library);
    fprintf(stderr, "%s\n", pressio_error_msg(library));
    exit(ec);
  }

  char* options_str = pressio_options_to_string(json_options);
  printf("%s\n", options_str);

  free(options_str);
  pressio_options_free(json_options);
  pressio_release(library);
  return 0;
}
