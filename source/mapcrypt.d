module mapcrypt;

private ubyte[256] bytes = (ubyte[] seed) {
        for (auto i = 0; i < seed.length; i++) {
            seed[i] = cast(ubyte) i;
        }
        return seed;
}(new ubyte[256]);

struct Table
{
    private
    {
        ubyte[] random;
        ubyte[] indexes = new ubyte[bytes.length];
        Table*  next;
        Table*  prev;
        Table*  tail;
    }
}

Table* createTables(int n)
{
    Table* table = createTable();
    Table* head  = table;
    while (n-- > 1)
    {
        table.next = table = createTable(table);
        head.tail  = table;
    }
    return head;
}

Table* createTables(ubyte[][] tables) {
    Table* head = createTable(null, tables[0]);
    Table* table = head;
    foreach (i; 1 .. tables.length) {
        table.next = table = createTable(table, tables[i]);
        head.tail = table;
    }
    return head;

}

Table* createTable(Table* parent = null, ubyte[] random = null)
{
    Table* table = new Table();
    table.prev   = parent;
    return assignStorages(table, random);
}

Table* assignStorages(Table* table, ubyte[] random) {
    import std.random : randomShuffle;

    if (random != null) {
        if (random.length != bytes.length) {
            throw new Exception("Invalid random array length");
        }
        table.random = random.dup;
    } else {
        table.random = randomShuffle(bytes.dup);
    }
    foreach (i; 0..table.indexes.length) {
        table.indexes[
            table.random[i]
        ] = cast(ubyte) i;
    }
    return table;
}

ubyte[] encrypt(Table* head, ubyte[] data)
{
    return encrypt0(head, data);
}

private ubyte[] encrypt0(Table* head, ubyte[] data)
{
    auto result = new ubyte[data.length];
    foreach (i, b; data)
    {
        result[i] = head.indexes[b];
    }
    if (head.next != null)
    {
        return encrypt(head.next, result);
    }
    return result;
}

ubyte[] decrypt(Table* table, ubyte[] data)
{
    return decrypt0(table.tail ? table.tail : table, data);
}

private ubyte[] decrypt0(Table* table, ubyte[] data)
{
    ubyte[] result = new ubyte[data.length];
    foreach (i, b; data)
    {
        result[i] = table.random[b];
    }
    if (table.prev)
    {
        return decrypt0(table.prev, result);
    }
    return result;
}

ubyte[][] tables(Table* table)
{
    ubyte[][] result;
    while (table)
    {
        result ~= table.random;
        table = table.next;
    }
    return result;
}

unittest
{
    import std.stdio : writeln;

    auto table = createTables(5);
    auto data = cast(ubyte[]) "Hello, World!";
    auto encrypted = encrypt(table, data);
    auto decrypted = decrypt(table, encrypted);
    assert(data == decrypted);

    foreach (i, t; tables(table))
    {
        writeln("Table ", i, ":");
        writeln(t);
        writeln("----------------");
    }

    auto table2 = createTables(tables(table));
    auto encrypted2 = encrypt(table2, data);
    assert(encrypted == encrypted2);
    auto decrypted2 = decrypt(table2, encrypted2);
    assert(data == decrypted2);
}