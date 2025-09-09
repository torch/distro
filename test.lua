print("=== Testing Fixed Torch ===")
local ok, torch = pcall(require, 'torch')
if ok then
    print("✓ torch loaded")
    local t = torch.Tensor(2,2):fill(1)
    print("✓ basic tensor:", t:sum())
    
    local ok_nn, nn = pcall(require, 'nn')
    if ok_nn then
        print("✓ nn loaded")
        local linear = nn.Linear(2, 1)
        local out = linear:forward(torch.randn(2))
        print("✓ neural network works")
    end
    
    local ok_img, image = pcall(require, 'image')
    if ok_img then
        print("✓ image loaded") 
    end
else
    print("❌ torch failed:", torch)
end
