import os
from math import sqrt
import xlwt
from absl import flags
from absl import app

flags.DEFINE_string(
    'name',
    default=None,
    help='Test case name')

FLAGS = flags.FLAGS
DEVICE_TFLOPS = 181

def main(_):
    name = FLAGS.name
    input_file = name+".txt"

    workbook = xlwt.Workbook(encoding= 'ascii')

    worksheet = workbook.add_sheet("benchmark")

    worksheet.write(0,0, "batch size")
    worksheet.write(0,1, "num heads")
    worksheet.write(0,2, "num heads * batch size")
    worksheet.write(0,3, "seqlen")
    worksheet.write(0,4, "head dim")
    worksheet.write(0,5, "run time on MI250/ms")
    worksheet.write(0,6, "tflops")
    worksheet.write(0,7, "util/%")

    batch_sizes = [1, 2, 8, 32, 64]
    num_heads = [16, 12]
    seqlens = [1, 2, 16, 32, 128, 256]
    head_dims = [64]
    configs = []
    for batch_size in batch_sizes:
        for num_head in num_heads:
            for seqlen in seqlens:
                for head_dim in head_dims:
                    configs.append([batch_size, num_head, seqlen, head_dim])

    for i, (batch_size, num_head, seqlen, head_dim) in enumerate(configs):
        index = i+1
        if name == 'batched_gemm_scale_softmax_gemm_permute_xdl_fp16':
            os.system(f'./{name}.cppout 0 1 1 {seqlen} {seqlen} {head_dim} {head_dim} {batch_size} {num_head} {1/sqrt(head_dim)}')
        else:
            os.system(f'./{name}.cppout 0 1 1 {seqlen} {seqlen} {head_dim} {head_dim} {batch_size * num_head} {1/sqrt(head_dim)}')
        worksheet.write(index, 0, batch_size)
        worksheet.write(index, 1, num_head)
        worksheet.write(index, 2, num_head * batch_size)
        worksheet.write(index, 3, seqlen)
        worksheet.write(index, 4, head_dim)

    with open(input_file) as f:
        index = 1
        for line in f.readlines():
            if line.startswith('Perf:'):
                time = line.split(' ')[1]
                tflops = line.split(' ')[3]
                worksheet.write(index, 5, time)
                worksheet.write(index, 6, tflops)
                worksheet.write(index, 7, 100*float(tflops)/DEVICE_TFLOPS)
                index += 1


    workbook.save(name+'.xls')

if __name__ == '__main__':
    app.run(main)
