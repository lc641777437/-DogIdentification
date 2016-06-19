
require 'torch'
require 'xlua'
require 'image'
require 'paths'
require 'nn'


op = xlua.OptionParser('load-images.lua [options]')
op:option{'-d', '--dir', action='store', dest='dir', help='directory to load', req=true}
op:option{'-e', '--ext', action='store', dest='ext', help='only load files of this extension', default='jpg'}
opt = op:parse()
op:summarize()

images = {}
number = {}
directory = io.open("path.txt","r")
ls={}
i=0
for l in directory:lines() do
    i=i+1
    classNumber=i
    if i<100 then
      opt.dir=l
      files = {}
      for file in paths.files(opt.dir) do   -- Go over all files in directory. We use an iterator, paths.files().
         if file:find(opt.ext .. '$') then  -- We only load files that match the extension
            table.insert(files, paths.concat(opt.dir,file)) -- and insert the ones we care about in our table
         end
      end
      
      if #files == 0 then   -- Check files
         error('given directory doesnt contain any files of type: ' .. opt.ext)
      end
      
      table.sort(files, function (a,b) return a < b end)    -- We sort files alphabetically, it's quite simple with table.sort()

      print('Found files')
      --print(files)

      for i,file in ipairs(files) do
        number[i]= classNumber
        table.insert(images, image.load(file)) -- load each image
      end
  end

end
directory:close()
local maxline = #ls
local count = 1

print('Loaded images')
--print(images)

data = images
label = number
torch.save('image-trainset.t7', {data:t(), label:t()})