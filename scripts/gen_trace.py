INNER_PC = 0x24
OUTER_PC = 0x30


def generate_trace():
    trace = []
    for i in range(1000):
        for j in range(5):
            taken = (j + 1) < 5
            trace.append((INNER_PC, taken))
        taken = (i + 1) < 1000
        trace.append((OUTER_PC, taken))
    return trace


def main():
    trace = generate_trace()

    with open("trace.txt", "w") as f:
        for pc, taken in trace:
            f.write(f"0x{pc:02X} {'T' if taken else 'NT'}\n")

    with open("trace.mem", "w") as f:
        for pc, taken in trace:
            f.write(f"{pc:08b}{1 if taken else 0}\n")

    total = len(trace)
    takens = sum(1 for _, t in trace if t)
    inner = sum(1 for pc, _ in trace if pc == INNER_PC)
    outer = sum(1 for pc, _ in trace if pc == OUTER_PC)

    print(f"Generated {total} branches")
    print(f"  Taken     : {takens}")
    print(f"  Not taken : {total - takens}")
    print(f"  Inner @ 0x{INNER_PC:02X} : {inner}")
    print(f"  Outer @ 0x{OUTER_PC:02X} : {outer}")
    print()
    print("Wrote: trace.txt, trace.mem")


if __name__ == "__main__":
    main()
