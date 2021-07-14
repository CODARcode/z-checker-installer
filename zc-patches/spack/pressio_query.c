#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "libpressio.h"


const char* option_type_string(enum pressio_option_type type) {
  switch(type) {
    case pressio_option_int8_type:
      return "int8";
    case pressio_option_int16_type:
      return "int16";
    case pressio_option_int32_type:
      return "int32";
    case pressio_option_int64_type:
      return "int64";
    case pressio_option_uint8_type:
      return "uint8";
    case pressio_option_uint16_type:
      return "uint16";
    case pressio_option_uint32_type:
      return "uint32";
    case pressio_option_uint64_type:
      return "uint64";
    case pressio_option_float_type:
      return "float";
    case pressio_option_double_type:
      return "double";
    case pressio_option_charptr_type:
      return "string";
    case pressio_option_charptr_array_type:
      return "strings";
    case pressio_option_userptr_type:
      return "void*";
    case pressio_option_data_type:
      return "pressio_data*";
    case pressio_option_unset_type:
      return "unset";
  }
  fprintf(stderr, "unexpected type\n");
  exit(1);
}

int print_compressor(FILE* out, struct pressio* library, const char* compressor_id) {
    printf("%s\n", compressor_id);

    struct pressio_compressor* compressor = pressio_get_compressor(library, compressor_id);
    if(compressor == NULL) {
      fprintf(stderr, "%s\n", pressio_error_msg(library));
      return pressio_error_code(library);
    }
    struct pressio_options* options = pressio_compressor_get_options(compressor);
    struct pressio_options* documentation = pressio_compressor_get_documentation(compressor);
    struct pressio_options* configuration = pressio_compressor_get_configuration(compressor);
    struct pressio_options_iter* iter = pressio_options_get_iter(options);

    fprintf(out, "# Options\n");
    while(pressio_options_iter_has_value(iter)) {
      const char* key = pressio_options_iter_get_key(iter);
      struct pressio_option* option = pressio_options_iter_get_value(iter);

      struct pressio_option* doc_op = NULL;
      const char* docs = NULL;
      enum pressio_options_key_status doc_status = pressio_options_exists(documentation, key);
      if(doc_status == pressio_options_key_set) {
        doc_op = pressio_options_get(documentation, key);
        docs = pressio_option_get_string(doc_op);
      }

      size_t n_entries = 0;
      const char** entries = NULL;
      struct pressio_option* conf_op = NULL;
      enum pressio_options_key_status config_status = pressio_options_exists(configuration, key);
      if(config_status == pressio_options_key_set) {
        conf_op = pressio_options_get(configuration, key);
        entries = pressio_option_get_strings(conf_op, &n_entries);
      }

      enum pressio_option_type type = pressio_option_get_type(option);
      
      if(config_status == pressio_options_key_set) {
        fprintf(out, "%s <%s> %s possible_values: {", key, option_type_string(type), docs);
        for (size_t i = 0; i < n_entries; ++i) {
          fprintf(out, "%s, ",  entries[i]);
          free((char*)entries[i]);
        }
        free(entries);
        fprintf(out, "}\n");

      } else {
        fprintf(out, "%s <%s> %s\n", key, option_type_string(type), docs);
      }


      pressio_option_free(option);
      pressio_option_free(doc_op);
      pressio_option_free(conf_op);
      pressio_options_iter_next(iter);
    }

    pressio_options_iter_free(iter);
    pressio_options_free(options);
    pressio_options_free(documentation);
    pressio_options_free(configuration);
    pressio_compressor_release(compressor);
    pressio_release(library);
    fprintf(out, "\n");

    return 0;
}

int main(int argc, char *argv[])
{

  struct pressio* library = pressio_instance();

  if(argc == 1) {
  const char* supported = pressio_supported_compressors();
  char* supported_copy = strdup(supported);
  char* saveptr = NULL;
  char* compressor = strtok_r(supported_copy, " ", &saveptr);
  do {
    printf("%s\n", compressor);
  } while ((compressor = strtok_r(NULL, " ", &saveptr)) != NULL);
  free(supported_copy);
  } else {
    for (int i = 1; i < argc; ++i) {
      print_compressor(stdout, library, argv[i]);
    }
  }
  
  return 0;
}
