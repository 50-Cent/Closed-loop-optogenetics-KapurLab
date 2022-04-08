function layers = adhocSequential()

layers = [
    imageInputLayer([4096*4, 1, 1])

    convolution2dLayer([3,1],8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer([2,1],'Stride',2)

    convolution2dLayer([3,1],16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer([2,1],'Stride',2)
  
    convolution2dLayer([3,1], 32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer([2,1],'Stride',2)
    
    convolution2dLayer([3,1],64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    averagePooling2dLayer([2,1],'Stride',2)
    
    convolution2dLayer([3,1],128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([2,1],'Stride',2)
    
    convolution2dLayer([3,1],256,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer([2,1],'Stride',2)
    
    dropoutLayer(0.2)
    fullyConnectedLayer(1)
    regressionLayer];

end