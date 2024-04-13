from pyspark.sql import SparkSession
from pyspark.sql.functions import mean, col, when

def main():
    # Initialize Spark Session
    spark = SparkSession.builder \
        .appName("Diabetes Data Analysis") \
        .getOrCreate()

    # 1. Load "csv" data into a DataFrame
    df = spark.read.csv("diabetes.csv", header=True, inferSchema=True)

    # Display the initial data for verification
    df.show()

    # 2. Update rows with BMI=0 with the mean BMI of non-zero values and write into a new dataframe
    mean_bmi = df.filter(df.BMI != 0).agg(mean(df.BMI)).first()[0]
    df_nonzero_BMI = df.withColumn("BMI", when(col("BMI") == 0, mean_bmi).otherwise(col("BMI")))

    # Display the updated DataFrame
    df_nonzero_BMI.show()

    # 3. Create a new dataframe that shows rows with age > 35
    df_outcome = df.filter(df.Age > 35)

    # Display the dataframe for age > 35
    df_outcome.show()

    # 4. Show only the rows where Diabetes Pedigree Function value is greater than or equal to 0.51
    df_pedigree = df.filter(df.DiabetesPedigreeFunction >= 0.51)

    # Display the DataFrame with DiabetesPedigreeFunction >= 0.51
    df_pedigree.show()

    # Stop the Spark session
    spark.stop()

if __name__ == "__main__":
    main()
