require 'torch'
require 'xlua'
require 'image'
require 'paths'
require 'nn'

op = xlua.OptionParser('load-images.lua [options]')
op:option{'-d', '--dir', action='store', dest='dir', help='directory to load', req=true}
op:option{'-e', '--ext', action='store', dest='ext', help='only load files of this extension', default='jpg'}
op:option{'-n', '--name', action='store', dest='name', help='test file name', default='test.jpg'}
opt = op:parse()
op:summarize()
print(opt.name)

count = 5

print('Loaded images')
trainset = {}
trainset = torch.load('image-trainset.t7')
--trainset.data = images
--trainset.label = number
--print(trainset)

classes = {}
file = io.open("class.txt","r")

i=0
for l in file:lines() do
    i=i+1
    if i<count then
        classes[i]= l
    end

end

print(classes)
file:close()

print(#trainset.data)

setmetatable(trainset, -- ignore setmetatable for now, it is a feature beyond the scope of this tutorial. It sets the index operator.
    {__index = function(t, i) 
                    return {t.data[i], t.label[i]} 
                end}
);

function trainset:size() 
    return #trainset.data --self.data:size(1) --16961 
end
print('just to test:',trainset:size()) -- just to test


net = nn.Sequential()
net:add(nn.SpatialConvolution(3, 6, 5, 5)) -- 3 input image channels, 6 output channels, 5x5 convolution kernel
net:add(nn.ReLU())                       -- non-linearity 

net:add(nn.SpatialMaxPooling(4,4,2,2))     -- A max-pooling operation that looks at 2x2 windows and finds the max.
net:add(nn.SpatialConvolution(6, 16, 5, 5)) -- the size of the image of the pool
net:add(nn.ReLU())                       -- non-linearity 

net:add(nn.SpatialMaxPooling(4,4,2,2))
net:add(nn.View(16*45*45))                    -- reshapes from a 3D tensor of 16*47*47 into 1D tensor of 200*200
net:add(nn.Linear(16*45*45, 200))             -- fully connected layer (matrix multiplication between input and weights)
net:add(nn.ReLU())                       -- non-linearity 

net:add(nn.Linear(200, 100))
net:add(nn.ReLU())                       -- non-linearity 

net:add(nn.Linear(100, count-1))                   -- 10 is the number of outputs of the network (in this case, 10 digits)

net:add(nn.LogSoftMax())                     -- converts the output to a log-probability. Useful for classification problems

criterion = nn.ClassNLLCriterion()
trainer = nn.StochasticGradient(net, criterion)
trainer.learningRate = 0.001
trainer.maxIteration = 20 -- just do 5 epochs of training.
trainer:train(trainset)
print('pass train')

file= "/home/supervisor/test/"..opt.name
test = {}
table.insert(test, image.load(file))

testset  = {}
testset.data = test

mean = {} -- store the mean, to normalize the test set in the future
stdv = {} -- store the standard-deviation for the future

predicted = net:forward(testset.data[1])
print(predicted:exp())
for i=1,#classes do
    print(classes[i], predicted[i])
end
