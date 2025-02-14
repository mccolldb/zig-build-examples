export fn fizz_buzz(n: usize) ?[*:0]const u8 {
    if (n % 5 == 0) {
        if (n % 3 == 0) {
            return "FizzBuzz";
        } else {
            return "Fizz";
        }
    } else if (n % 3 == 0) {
        return "Buzz";
    }
    return null;
}
