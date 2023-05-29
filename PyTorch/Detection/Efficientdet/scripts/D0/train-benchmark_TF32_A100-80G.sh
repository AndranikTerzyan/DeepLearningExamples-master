#!/bin/bash

function get_dataloader_workers {
    gpus=$(nvidia-smi -i 0 --query-gpu=count --format=csv,noheader)
    core=$(nproc --all)
    workers=$((core/gpus-2))
    workers=$((workers>16?16:workers))
    echo ${workers}
}
WORKERS=$(get_dataloader_workers)

./distributed_train.sh ${NUM_PROC:-8} /workspace/object_detection/datasets/coco --model efficientdet_d0 -b 80 --lr 0.9 --opt fusedmomentum --warmup-epochs 50 --lr-noise 0.4 0.9 --output /model --worker ${WORKERS} --fill-color mean --model-ema --model-ema-decay 0.999 --eval-after 200 --epochs 5 --resume --smoothing 0.0 --pretrained-backbone-path /backbone_checkpoints/jocbackbone_statedict_B0.pth --memory-format nchw --sync-bn --fused-focal-loss --seed 12711 --benchmark-steps 500 --benchmark