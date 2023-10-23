# Quick Sort function
def quick_sort(arr):
  if len(
      arr
  ) <= 1:  # if array length is 1 or less, we return the array (base case)
    return arr
  pivot = arr[len(arr) // 2]  # picking a pivot as the middle element
  left = [x for x in arr if x < pivot]  # elements less than pivot
  middle = [x for x in arr if x == pivot]  # elements equal to pivot
  right = [x for x in arr if x > pivot]  # elements greater than pivot
  return quick_sort(left) + middle + quick_sort(
      right)  # recursive calls for left,right and concatenate


# Merge Sort function
def merge_sort(arr):
  if len(
      arr
  ) <= 1:  # if array length is 1 or less, we return the array (base case)
    return arr
  mid = len(arr) // 2  # getting the mid of the array
  left = arr[:mid]  # dividing the array into left half
  right = arr[mid:]  # dividing the array into right half
  return merge(
      merge_sort(left),
      merge_sort(right))  # recursive call for left and right half and merge


# Merge function to merge two array
def merge(left, right):
  result = []  # result array where the merged array will be stored
  i = j = 0  # initializing pointers for left and right arrays
  # until we reach the end of either L or M, pick larger among
  # elements L and M and place them in the correct position at A[p..r]
  while i < len(left) and j < len(right):
    if left[i] < right[j]:
      result.append(left[i])
      i += 1
    else:
      result.append(right[j])
      j += 1
  result.extend(left[i:])
  result.extend(right[j:])
  return result


# Bubble Sort function
def bubble_sort(arr):

  def swap(i, j):  # swap function to swap two elements in list
    arr[i], arr[j] = arr[j], arr[i]

  n = len(arr)
  swapped = True
  x = -1
  while swapped:
    swapped = False
    x = x + 1
    for i in range(1, n - x):
      if arr[i - 1] > arr[i]:  # if previous is greater than current, swap them
        swap(i - 1, i)
        swapped = True
  return arr


# The main function to orchestrate the above functions
def sort_files():
  file_name = input("Enter file to sort: ")  # get the file to sort
  # create the name for the output file after processing the input filename
  output_file_name = file_name.split(".")[0] + "_sorted." + file_name.split(
      ".")[1]
  with open(file_name, 'r') as file:  # opening the file in read mode
    arr = list(
        map(int,
            file.read().split()
            ))  # read from the file, split by space and map into integer list
  print("Please select a sorting method:")
  print("1. Quick sort")
  print("2. Merge sort")
  print("3. Bubble sort")
  method = int(input("Sorting Method: "))  # ask user for the sorting method
  if method == 1:
    sorted_arr = quick_sort(arr)  # Call Quick Sort
  elif method == 2:
    sorted_arr = merge_sort(arr)  # Call Merge Sort
  elif method == 3:
    sorted_arr = bubble_sort(arr)  # Call Bubble Sort
  else:
    print("Invalid choice")
    return
  # Write the sorted content to new file
  with open(output_file_name, 'w') as file:  # open a new file in write mode
    # convert integer list to string and join by a space and write
    file.write(' '.join(map(str, sorted_arr)))
  print(f"Sorted data written to {output_file_name}.")


if __name__ == "__main__":
  sort_files()  # sort_files() function is called when the program starts
