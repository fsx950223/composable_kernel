#pragma once
#include "ConstantTensorDescriptor.cuh"

template <class Float, class Desc, class F>
__device__ void threadwise_4d_tensor_pointwise_operation_unary(Desc, Float* __restrict__ p, F f)
{
    constexpr auto I0 = Number<0>{};
    constexpr auto I1 = Number<1>{};
    constexpr auto I2 = Number<2>{};
    constexpr auto I3 = Number<3>{};

    constexpr auto desc = Desc{};

#if 0
    if(threadIdx.x == 0)
    {
        print_ConstantTensorDescriptor(desc, "threadwise_4d_tensor_op_unary: ");
    }
#endif

    for(unsigned did0 = 0; did0 < desc.GetLength(I0); ++did0)
    {
        for(unsigned did1 = 0; did1 < desc.GetLength(I1); ++did1)
        {
            for(unsigned did2 = 0; did2 < desc.GetLength(I2); ++did2)
            {
                for(unsigned did3 = 0; did3 < desc.GetLength(I3); ++did3)
                {
                    const unsigned dindex = desc.Get1dIndex(did0, did1, did2, did3);

                    f(p[dindex]);
                }
            }
        }
    }
}

// TODO: in order to optimize mem access for different mem type,
// need to write specialized version
template <class Float, class SrcDesc, class DstDesc, class RefDesc, class Reorder, class F>
__device__ void
threadwise_4d_tensor_pointwise_operation_binary_reorder(SrcDesc,
                                                        Float* const __restrict__ p_src,
                                                        DstDesc,
                                                        Float* __restrict__ p_dst,
                                                        RefDesc,
                                                        Reorder,
                                                        F f)
{
    constexpr auto I0 = Number<0>{};
    constexpr auto I1 = Number<1>{};
    constexpr auto I2 = Number<2>{};
    constexpr auto I3 = Number<3>{};

    constexpr unsigned IT0 = Reorder{}.Get(I0);
    constexpr unsigned IT1 = Reorder{}.Get(I1);
    constexpr unsigned IT2 = Reorder{}.Get(I2);
    constexpr unsigned IT3 = Reorder{}.Get(I3);

    constexpr auto src_desc = SrcDesc{};
    constexpr auto dst_desc = DstDesc{};
    constexpr auto ref_desc = RefDesc{};

    for(unsigned did0 = 0; did0 < ref_desc.GetLength(I0); ++did0)
    {
        for(unsigned did1 = 0; did1 < ref_desc.GetLength(I1); ++did1)
        {
            for(unsigned did2 = 0; did2 < ref_desc.GetLength(I2); ++did2)
            {
                for(unsigned did3 = 0; did3 < ref_desc.GetLength(I3); ++did3)
                {
                    const unsigned aindex = src_desc.Get1dIndex(did0, did1, did2, did3);

                    const unsigned did[4] = {did0, did1, did2, did3};

                    const unsigned bindex =
                        dst_desc.Get1dIndex(did[IT0], did[IT1], did[IT2], did[IT3]);

                    f(p_src[aindex], p_dst[bindex]);
                }
            }
        }
    }
}

template <class Float, class Desc>
__device__ void threadwise_4d_tensor_set_zero(Desc, Float* __restrict__ p)
{
    auto f_set_zero = [](Float& v) { v = Float(0); };

    threadwise_4d_tensor_pointwise_operation_unary<Float, Desc, decltype(f_set_zero)>(
        Desc{}, p, f_set_zero);
}

template <class Float, class SrcDesc, class DstDesc, class RefDesc, class Reorder>
__device__ void threadwise_4d_tensor_copy_reorder(
    SrcDesc, Float* const __restrict__ p_src, DstDesc, Float* __restrict__ p_dst, RefDesc, Reorder)
{
    auto f_copy = [](const Float& src, Float& dst) { dst = src; };

    threadwise_4d_tensor_pointwise_operation_binary_reorder<Float,
                                                            SrcDesc,
                                                            DstDesc,
                                                            RefDesc,
                                                            Reorder,
                                                            decltype(f_copy)>(
        SrcDesc{}, p_src, DstDesc{}, p_dst, RefDesc{}, Reorder{}, f_copy);
}

template <class Float, class SrcDesc, class DstDesc, class RefDesc>
__device__ void threadwise_4d_tensor_copy(
    SrcDesc, Float* const __restrict__ p_src, DstDesc, Float* __restrict__ p_dst, RefDesc)
{
    auto reorder = Sequence<0, 1, 2, 3>{};

    threadwise_4d_tensor_copy_reorder<Float, SrcDesc, DstDesc, RefDesc, decltype(reorder)>(
        SrcDesc{}, p_src, DstDesc{}, p_dst, RefDesc{}, reorder);
}

template <class Float, class Desc, class IDim, class NShift>
__device__ void threadwise_4d_tensor_shift_down(Desc, Float* __restrict__ p, IDim, NShift)
{
    constexpr auto I0 = Number<0>{};
    constexpr auto I1 = Number<1>{};
    constexpr auto I2 = Number<2>{};
    constexpr auto I3 = Number<3>{};

    constexpr auto desc = Desc{};

#if 0
    if(threadIdx.x == 0)
    {
        print_ConstantTensorDescriptor(desc, "threadwise_4d_tensor_shift_down: ");
    }
#endif

    constexpr unsigned nshift = NShift::mValue;

    constexpr unsigned did0_end =
        is_same<decltype(I0), IDim>::value ? desc.GetLength(I0) - nshift : desc.GetLength(I0);

    constexpr unsigned did1_end =
        is_same<decltype(I1), IDim>::value ? desc.GetLength(I1) - nshift : desc.GetLength(I1);

    constexpr unsigned did2_end =
        is_same<decltype(I2), IDim>::value ? desc.GetLength(I2) - nshift : desc.GetLength(I2);

    constexpr unsigned did3_end =
        is_same<decltype(I3), IDim>::value ? desc.GetLength(I3) - nshift : desc.GetLength(I3);

    for(unsigned did0 = 0; did0 < did0_end; ++did0)
    {
        for(unsigned did1 = 0; did1 < did1_end; ++did1)
        {
            for(unsigned did2 = 0; did2 < did2_end; ++did2)
            {
                for(unsigned did3 = 0; did3 < did3_end; ++did3)
                {
                    const unsigned dindex = desc.Get1dIndex(did0, did1, did2, did3);

                    const unsigned sindex = dindex + nshift * desc.GetStride(IDim{});

                    p[dindex] = p[sindex];
                }
            }
        }
    }
}
