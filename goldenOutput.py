## You can use any image given that it is of size 512x512. We decided to make use of the random function to generate multiple tests


import numpy as np
from math import floor
import csv
# Define the size of the array
rows = 512
cols = 512  
def conImg(image,kernal,convSize):
    ## Initial convoluted image
    outputImg = np.zeros((convSize, convSize),dtype=np.int32)

    for i in range(convSize):
        for j in range(convSize):
            # Calculate the start and end indices for the current patch
            start_i, start_j = i, j
            end_i, end_j = start_i + 3, start_j + 3

            patch = image[start_i:end_i, start_j:end_j]

            outputImg[i, j] = (np.sum(patch * kernal))
    return outputImg

def save_to_csv(convImg, image):
    outputImgFile = "outputImg.txt"
    inpututImgFile = "inputImg.txt"
    with open(inpututImgFile, 'w') as input_file,open(outputImgFile,'w') as output_file:
        for row in convImg:
            for col in row:
                input_file.write(f"{format(col & 0xFFF, '03x')}\n")


        for row in image:
            for col in row:
                output_file.write(f"{format(col & 0xFFF, '03x')}\n")

# Generate a numpy array of random integers from 0 to 255 to simulate an image of size 512x512
image = np.random.randint(0, 256, size=(rows, cols), dtype=np.uint8)

## Kernal/Filter
kernal = np.array([[1,1,1],[1,-8,1],[1,1,1]])

outputImg = conImg(image,kernal,510)

print(image,'\n\n',outputImg)

save_to_csv(image,outputImg)