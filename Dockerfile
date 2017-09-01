FROM scratch
ADD example-multi.linux /example-multi
ENTRYPOINT ["/example-multi"]
