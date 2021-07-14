#include <cmath> //for exp and log
#include <iterator>
#include <map>
#include <sstream>
#include "libpressio_ext/cpp/data.h" //for access to pressio_data structures
#include "libpressio_ext/cpp/compressor.h" //for the libpressio_compressor_plugin class
#include "libpressio_ext/cpp/options.h" // for access to pressio_options
#include "libpressio_ext/cpp/pressio.h" //for the plugin registries
#include "pressio_options.h"
#include "pressio_data.h"
#include "pressio_compressor.h"
#include "pressio_version.h"
#include "std_compat/memory.h"


// TODO uncomment finish the log and inverse log transforms
// struct pressiozchecker_log_invtransform {
//   template <class T>
//   pressio_data operator()(T const* begin, T const* end) {
//     auto data = pressio_data::owning(pressio_dtype_from_type<T>(), dims);
//     T* out_ptr = static_cast<T*>(data.data());
// 
//     size_t len = end - begin;
//     for (size_t i = 0; i < len; ++i) {
//       out_ptr[i] = exp(begin[i]) - min_value;
//     }
//     return data;
//   }
//   double min_value;
//   std::vector<size_t> dims;
// };
// 
// struct pressiozchecker_log_transform {
//   template <class T>
//   pressio_data operator()(T const* begin, T const* end) {
//     auto data = pressio_data::owning(pressio_dtype_from_type<T>(), dims);
//     T* out_ptr = static_cast<T*>(data.data());
// 
//     size_t len = end - begin;
//     for (size_t i = 0; i < len; ++i) {
//       out_ptr[i] = log(begin[i] + min_value);
//     }
//     return data;
//   }
//   double min_value;
//   std::vector<size_t> dims;
// };

class zcheckerapi_plugin: public libpressio_compressor_plugin {
  public:
    struct pressio_options get_options_impl() const override {
      struct pressio_options options;
      set_meta(options, "zcheckerapi:compressor", compressor_id, compressor);
      set(options, "zcheckerapi:check_options", check_options);
      set(options, "zcheckerapi:error_bound", error_bound);
      set(options, "zcheckerapi:abs_error_bound_name", abs_error_bound_name);
      set(options, "zcheckerapi:abs_error_bound", abs_error_bound);
      set(options, "zcheckerapi:rel_error_bound_name", rel_error_bound_name);
      set(options, "zcheckerapi:rel_error_bound", rel_error_bound);
      set(options, "zcheckerapi:pw_rel_error_bound_name", pw_rel_error_bound_name);
      set(options, "zcheckerapi:pw_rel_error_bound", pw_rel_error_bound);

      return options;
    }
#if (LIBPRESSIO_MINOR_VERSION >= 65) || (LIBPRESSIO_MAJOR_VERSION >= 1)
    struct pressio_options get_documentation_impl() const override {
      struct pressio_options options;
      set_meta_docs(options, "zcheckerapi:compressor", "compressor to use with Z-Checker", compressor);
      set(options, "zcheckerapi:check_options", R"(nonzero if zcheckerapi should be more agressive in validating
        configuration by calling compressor->check_options should be called in compress)");
      set(options, "pressio:description", "helper which abstracts across names for error bounds and provides alternative implementations for those that do not have some type of bounds");
      set(options, "zcheckerapi:error_bound", "which error bound mode to use");
      set(options, "zcheckerapi:abs_error_bound_name", "the name of the absolute error bound setting on compressor");
      set(options, "zcheckerapi:abs_error_bound", "the absolute error bound");
      set(options, "zcheckerapi:rel_error_bound_name", "the name of the value range relative error bound setting on compressor");
      set(options, "zcheckerapi:rel_error_bound", "the value range relative error bound");
      set(options, "zcheckerapi:pw_rel_error_bound_name", "the name of the point-wise relative error bound on compressor");
      set(options, "zcheckerapi:pw_rel_error_bound", "the point-wise relative range relative error bound");
      return options;
    }
#endif

    struct pressio_options get_configuration_impl() const override {
      struct pressio_options options;
      pressio_options config = compressor->get_configuration();
      int32_t is_thread_safe;
      if(config.get("pressio:thread_safe", &is_thread_safe) != pressio_options_key_set) {
        is_thread_safe = static_cast<int32_t>(pressio_thread_safety_single);
      }
      set(options, "pressio:thread_safe", is_thread_safe);
      set(options, "zcheckerapi:error_bound", std::vector<std::string>{"abs", "pw_rel", "rel"});
      return options;
    }

    int set_options_impl(struct pressio_options const& options) override {
      get_meta(options, "zcheckerapi:compressor", compressor_plugins(), compressor_id, compressor);
      get(options, "zcheckerapi:check_options", &check_options);
      get(options, "zcheckerapi:error_bound", &error_bound);
      get(options, "zcheckerapi:abs_error_bound_name", &abs_error_bound_name);
      get(options, "zcheckerapi:abs_error_bound", &abs_error_bound);
      get(options, "zcheckerapi:rel_error_bound_name", &rel_error_bound_name);
      get(options, "zcheckerapi:rel_error_bound", &rel_error_bound);
      get(options, "zcheckerapi:pw_rel_error_bound_name", &pw_rel_error_bound_name);
      get(options, "zcheckerapi:pw_rel_error_bound", &pw_rel_error_bound);
      return 0;
    }

    int compress_impl(const pressio_data *input, struct pressio_data* output) override {
      pressio_options opts = compressor->get_options();
      pressio_data tmp;
      if(error_bound == "abs") {
        if(abs_error_bound_name.empty()) { 
          return set_error(1, "abs_error_bound_name must be set");
        } else {
          if(opts.cast_set(abs_error_bound_name, abs_error_bound, pressio_conversion_special) != pressio_options_key_set) {
            return set_error(2, "unable to set error_bound " + abs_error_bound_name);
          }
        }
      } else if (error_bound == "rel"){
        if(!rel_error_bound_name.empty()) {
          if(opts.cast_set(rel_error_bound_name, rel_error_bound, pressio_conversion_special) != pressio_options_key_set) {
            return set_error(2, "unable to set error_bound " + rel_error_bound_name);
          }
        } else if (!abs_error_bound_name.empty()){
          if(opts.cast_set(abs_error_bound_name, compute_rel_bound(input), pressio_conversion_special) != pressio_options_key_set) {
            return set_error(2, "unable to set error_bound " + abs_error_bound_name);
          }
        } else {
          return set_error(3, "either abs_error_bound_name or rel_error_bound_name must be set");
        }
      } else if (error_bound == "pw_rel") {
        if(!pw_rel_error_bound_name.empty()) {
          if(opts.cast_set(pw_rel_error_bound_name, pw_rel_error_bound, pressio_conversion_special) != pressio_options_key_set) {
            return set_error(2, "unable to set error_bound " + pw_rel_error_bound_name);
          }
        } else if (!abs_error_bound_name.empty()){
          //TODO finish the pw_rel log transform; return an error for now
//          auto params = compute_pw_rel_bound(input);
//          opts.cast_set(abs_error_bound_name, params.bound, pressio_conversion_special);
//          tmp = pressio_data_for_each<pressio_data>(*input, pressiozchecker_log_transform{params.min_value,input->dimensions()});
//          input = &tmp;
          return set_error(3, "pw_rel abs transform not implemented yet");
        } else {
          return set_error(3, "either abs_error_bound_name or pw_rel_error_bound_name must be set");
        }
      }
      if (check_options && compressor->check_options(opts)) {
        return set_error(compressor->error_code(), compressor->error_msg());
      }
      if (compressor->set_options(opts)) {
        return set_error(compressor->error_code(), compressor->error_msg());
      }
      return compressor->compress(input, output);
    }

    int decompress_impl(const pressio_data *input, struct pressio_data* output) override {
      int rc = compressor->decompress(input, output);
      //TODO for pw_rel, we may need to do an inverse log transform after calling decompress

      return rc;
    }

    void set_name_impl(const std::string& new_name) override {
      compressor->set_name(new_name + "/" + compressor->prefix());
    }

    const char* version() const override {
      return "0.0.0";
    }

    const char* prefix() const override {
      return "zcheckerapi";
    }

    std::shared_ptr<libpressio_compressor_plugin> clone() override {
      return compat::make_unique<zcheckerapi_plugin>(*this);
    }

  private:

    double compute_rel_bound(const pressio_data* input) {
      pressio_metrics error_stat = metrics_plugins().build("error_stat");
      error_stat->begin_compress(input, input);
      error_stat->end_compress(input, input, 0);
      error_stat->begin_decompress(input, input);
      error_stat->end_decompress(input, input, 0);

      double value_range = 0;
#if (LIBPRESSIO_MINOR_VERSION >= 65) || (LIBPRESSIO_MAJOR_VERSION >= 1)
      auto metrics_results = error_stat->get_metrics_results({});
#else
      auto metrics_results = error_stat->get_metrics_results();
#endif
      metrics_results.get("error_stat:value_range", &value_range);

      return value_range*rel_error_bound;
    }

    struct pw_bound_params{
      double min_value = 0;
      double bound = 0;
    };

    pw_bound_params compute_pw_rel_bound(const pressio_data* input) {
      pw_bound_params params;
      pressio_metrics error_stat = metrics_plugins().build("error_stat");
      error_stat->begin_compress(input, input);
      error_stat->end_compress(input, input, 0);
      error_stat->begin_decompress(input, input);
      error_stat->end_decompress(input, input, 0);

#if (LIBPRESSIO_MINOR_VERSION >= 65) || (LIBPRESSIO_MAJOR_VERSION >= 1)
      auto metrics_results = error_stat->get_metrics_results({});
#else
      auto metrics_results = error_stat->get_metrics_results();
#endif
      metrics_results.get("error_stat:value_min", &params.min_value);

      //TODO finish the code that computes the corresponding abs_error_bound
      //params.bound = ???;
      return params;
    }

    pressio_compressor compressor = compressor_plugins().build("noop");
    std::string compressor_id = "noop";
    std::string error_bound = "abs";
    std::string abs_error_bound_name;
    std::string rel_error_bound_name;
    std::string pw_rel_error_bound_name;
    double abs_error_bound = 0;
    double rel_error_bound = 0;
    double pw_rel_error_bound = 0;
    int32_t check_options = 1;
};

static pressio_register compressor_zcheckerapi_plugin(compressor_plugins(), "zcheckerapi", [](){return compat::make_unique<zcheckerapi_plugin>(); });

