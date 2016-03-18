# Libra

Libra is an experiment to create a cluster-internal service-specific load
balancer using off-the-shelf components.

<!-- markdown-toc start - Don't edit this section. Run M-x markdown-toc-generate-toc again -->
**Table of Contents**

- [Libra](#libra)
    - [What is it?](#what-is-it)
    - [Usage](#usage)
    - [License](#license)

<!-- markdown-toc end -->

## What is it?

It uses:

- consul for service discovery (and thus consul-template for templating)
- traefik for load balancing
- dumb-init for an init script

And it all runs in Docker, to boot.

## Usage

To run it in your cluster, run this:

```
docker run --rm -name=${APP}-lb -e SERVICE=${APP} --rm -p 8000:80 asteris-llc/libra:latest
```

Where `APP` is the Consul application you would like balanced. Then, connect to
`:8000` and you're done.

## License

Apache 2.0. See [LICENSE](LICENSE).
