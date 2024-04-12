#### Mapcrypt

A dummy encryptation approach.

The idea is pretty simple, an array of random located bytes is generated. Then, those bytes are mapped to their respective index. For example:
```text
random [
    4 -> 0
    1 -> 1
    0 -> 2
    2 -> 3
    3 -> 4
]

indexes [
    0 -> 4
    1 -> 1
    2 -> 0
    3 -> 2
    4 -> 4
]
```

Once you need to encrypt some data, it will look for every byte and start encrypting.
```text
input: 4 3 2 1 0

random [
    4 -> 0
    1 -> 1
    0 -> 2
    2 -> 3
    3 -> 4 
]

output: 0 4 3 1 2
```

And for decryption it is opposite, it will look up in indexes array.

```text
input: 0 4 3 1 2

indexes [
    0 -> 4
    1 -> 1
    2 -> 0
    3 -> 2
    4 -> 4
]

output: 4 3 2 1 0
```

The trick here is that you can create infinite layers of encryption:
```text
Encrypt:
layer 1 input : 4 3 2 1 0
layer 1 output: 0 4 3 1 2
layer 2 input : 0 4 3 1 2 (2nd layer)
layer 2 output: 4 1 2 3 0
(and so on...)

Decrypt:
layer 2 input : 4 1 2 3 0 (2nd layer)
layer 2 out   : 0 4 3 1 2
layer 1 input : 0 4 3 1 2
layer 1 output: 4 3 2 1 0
```

That is all. I hope my brain did not mess up something in the examples...
