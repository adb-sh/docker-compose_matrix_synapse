docker run -it --rm \
    --mount type=volume,src=synapse-data,dst=/data \
    -e SYNAPSE_SERVER_NAME=your.domain \
    -e SYNAPSE_REPORT_STATS=yes \
    matrixdotorg/synapse:latest generate
