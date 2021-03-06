/*******************************************************************************
* Copyright 2016-2017 Intel Corporation
*
* Licensed under the Apache License, Version 2.0 (the "License");
* you may not use this file except in compliance with the License.
* You may obtain a copy of the License at
*
*     http://www.apache.org/licenses/LICENSE-2.0
*
* Unless required by applicable law or agreed to in writing, software
* distributed under the License is distributed on an "AS IS" BASIS,
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
* See the License for the specific language governing permissions and
* limitations under the License.
*******************************************************************************/

#ifndef CPU_REORDER_PD_HPP
#define CPU_REORDER_PD_HPP

#include <assert.h>

#include "c_types_map.hpp"
#include "reorder_pd.hpp"
#include "cpu_engine.hpp"
#include "cpu_memory.hpp"
#include "cpu_primitive.hpp"
#include "type_helpers.hpp"
#include "utils.hpp"

namespace mkldnn {
namespace impl {
namespace cpu {

struct cpu_reorder_pd_t: public reorder_pd_t {
    using cpu_memory_pd_t = cpu_memory_t::pd_t;

    cpu_reorder_pd_t(const cpu_memory_pd_t *input_pd,
            const cpu_memory_pd_t *output_pd,
            const float alpha, const float beta)
        : reorder_pd_t(input_pd->engine(), alpha, beta)
        , input_pd_(*input_pd), output_pd_(*output_pd) {}
    virtual ~cpu_reorder_pd_t() {}

    virtual const cpu_memory_pd_t *input_pd(int index = 0) const override
    { return index == 0 ? &input_pd_ : nullptr; }
    virtual const cpu_memory_pd_t *output_pd(int index = 0) const override
    { return index == 0 ? &output_pd_ : nullptr; }

    virtual int n_inputs() const override { return 1; }
    virtual int n_outputs() const override { return 1; }

protected:
    cpu_memory_pd_t input_pd_, output_pd_;
};

}
}
}

#endif

// vim: et ts=4 sw=4 cindent cino^=l0,\:0,N-s
