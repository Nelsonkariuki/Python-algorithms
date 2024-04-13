from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .appName("MaxPrimeNumber") \
    .getOrCreate()

# Create an RDD with N integers
N = 121000
numbers = spark.sparkContext.parallelize(range(2, N))

# Function to check if a number is prime
def is_prime(num):
    if num <= 1:
        return False
    for i in range(2, int(num**0.5) + 1):
        if num % i == 0:
            return False
    return True

# Filter the RDD to get prime numbers
prime_numbers = numbers.filter(is_prime)

# Get the maximum prime number
max_prime = prime_numbers.max()

# Print the maximum prime number
print("Max Prime Number:", max_prime)

spark.stop()
