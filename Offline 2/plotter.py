import matplotlib.pyplot as plt

input = open("result.txt", "r")
param = input.readline()
metric = input.readline().split()

x = []
network_throughputs = []
end_to_end_delay = []
packet_delivery_ratio = []
packet_drop_ratio = []

for line in input:
    if len(line.split()) == 1:
        x.append(int(line))
    else:
        splitter = line.split()
        network_throughputs.append(float(splitter[0]))
        end_to_end_delay.append(float(splitter[1]))
        packet_delivery_ratio.append(float(splitter[2]))
        packet_drop_ratio.append(float(splitter[3]))
input.close()

# plots

plt.plot(x, network_throughputs, color="b")
plt.ylabel(metric[0].replace("-", " "))
plt.xlabel(param.replace("-", " "))
plt.show()

plt.plot(x, end_to_end_delay, color="g")
plt.ylabel(metric[1].replace("-", " "))
plt.xlabel(param.replace("-", " "))
plt.show()

plt.plot(x, packet_delivery_ratio, color="r")
plt.ylabel(metric[2].replace("-", " "))
plt.xlabel(param.replace("-", " "))
plt.show()

plt.plot(x, packet_drop_ratio, color="y")
plt.ylabel(metric[3].replace("-", " "))
plt.xlabel(param.replace("-", " "))
plt.show()
