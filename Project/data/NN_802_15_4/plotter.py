import matplotlib.pyplot as plt
import numpy as np

# Define the filenames containing the data
filenames = ['gamma_0.txt', 'gamma_3.txt', 'gamma_6.txt', 'gamma_9.txt', 'gamma_12.txt', 'gamma_15.txt']

param = 'Number of nodes'
# Define the data points to plot
data_points = ['Network Throughput(kilobits/sec)', 'Average Delay(sec)', 'Packet Delivery Ratio(%)', 'Packet Drop Ratio(%)', 'Energy Consumed(J)']

# Create a new figure and axis object for each data point
fig, axs = plt.subplots(5, 1, figsize=(6, 12))

# Loop through each data point and plot the data
for i, data_point in enumerate(data_points):
    # Loop through each file and plot the data for the current data point
    for filename in filenames:
        x = []
        y = []
        
        ff = open(filename, "r")
        ff.readline()
        ff.readline()
        for line in ff:
            if len(line.split()) == 1:
                x.append(int(line))
            else:
                splitter = line.split()
                
                y.append(float(splitter[i]))               

        # Plot the data on the current axis
        axs[i].plot(x, y, label=filename)

    # Set the axis labels and title for the current axis
    axs[i].set_xlabel(param)
    axs[i].set_ylabel(data_point)
    # axs[i].set_title(f'Plot of {data_point}')

    # Add a legend to the current axis
    axs[i].legend()

# Adjust the spacing between subplots
fig.tight_layout()

# Show the plot
plt.show()
