# ClothCap

## Segmentation

### 原始方法
1. segmentation这一步的作用在于对scan的序列进行`per-vertex`的分割，得到每个顶点所属的类别（上衣、裤子、皮肤）。按照paper的说法由于实际获取的scan序列含有噪声等因素，直接对scan做分割效果不好，所以先采用`single-mesh-alignment`的方法，使用`SMPL`模型去fit每一帧的scan，得到一个序列的alignments，然后在此基础上做分割。
2. segmentation的主要方法是使用`MRF(Markov Random Field)`来解分割的优化问题，其中的能量函数分为两项，unary term和pairwise term，详细的介绍见paper。简略的来说就是unary term主要是计算每个顶点的energy，pairwise term根据顶点的拓扑关系计算每一对顶点的energy，这两项energy均与每个顶点的label相关，因此优化最小化总体energy就可以获得每个顶点的label。这是一个很典型的MRF或CRF问题。

### 问题与解决
> - 在paper的描述中，由第一步single-mesh-alignment得到了对应于原始序列scan的一系列alignments，接下来在segmentation这一步中，采用的是对alignments分割的方法，而不是对scan进行分割。因此在计算unary term时，采用了寻找最近邻点（KNN)的方法，从scan中获取颜色信息来计算unary term。由于在single-mesh-alignment这一步中，获得的alignments并不完全准确（fit效果不好），因此在计算unary时就会出现误差，从而影响分割结果。
> - 现有的解CRF或MRF的库主要都是应用在图像分割上，因此拓展到3D Mesh场景下有一定困难，传统方法如meanfield等效果不佳。造成困难的原因在于这些库没有充分利用上3D Mesh的拓扑连接关系，因此无法很好地解决问题

针对以上问题采用的相应的解决方法为：

1. 直接对scan序列进行分割，这样就不再需要第一步single-mesh-alignment的结果，根据实验结果来看直接对scan做分割比按照paper里的方法来做效果要好。可能的原因在于咱们自己的scan序列本身效果就很好，因此直接分割可以有较好的结果。
2. 对于解优化问题，最后使用了`gco`库来解决。这个库的优势在于可以手动制定数据的拓扑结构，这样就可以泛华的解决在任意graph上的优化问题。

### 关键点
1. 在paper中第一帧在计算unary时，首先对这一帧采用`kmeans`的方法，利用颜色信息得到一个初始分类，根据这个初始分类label来计算第一帧的unary。而在之后的每一帧，则采用`GMM`的方法来计算unary。这里需要注意的是，**在从第二帧之后开始，每一帧计算unary都需要训练一个GMM模型，而训练数据应该使用之前所有帧的分割label，而不是只采用前一帧的分割label**，这样可以保证随着分割的不断进行，每一帧训练得到的GMM效果会更加的趋于稳定，特别是在衣服皮肤颜色区别不是很大的时候，也会有较好的结果。
2. 分割主要利用的是HSV颜色特征，之前曾加入了SDF（Shape Diameter Function）特征，但是在某些情况下会影响分割结果，比如手的上臂和小腿部分，两者的sdf特征区别就很不明显，会引入误分类的问题。


