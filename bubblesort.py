# Creating a bubble sort function
#importing time function
import time
time=time.time_ns()
def bubble_sort(list1):
    # the  Outer loop for traverse the entire list
    for i in range(0, len(list1) - 1):
        for j in range(len(list1) - 1):
            if (list1[j] > list1[j + 1]):
                temp = list1[j]
                list1[j] = list1[j + 1]
                list1[j + 1] = temp
    return list1


list1 = [5, 3, 8, 6, 7, 2]
print("The unsorted list is: ", list1)
# this help calling the bubble sort function
print("The sorted list is: ", bubble_sort(list1),"time for execution" , time, "ns")
