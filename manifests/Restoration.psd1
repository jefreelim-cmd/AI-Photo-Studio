@{

    Models = @(
        @{
            Name        = "RealESRGAN_x4plus"
            Category    = "upscale_models"
            Version     = "1.0"
            FileName    = "RealESRGAN_x4plus.pth"
            Uri         = ""
            Sha256      = ""
            Required    = $true
        }

        @{
            Name        = "GFPGANv1.4"
            Category    = "facerestore_models"
            Version     = "1.4"
            FileName    = "GFPGANv1.4.pth"
            Uri         = ""
            Sha256      = ""
            Required    = $true
        }

        @{
            Name        = "CodeFormer"
            Category    = "facerestore_models"
            Version     = "0.1"
            FileName    = "codeformer.pth"
            Uri         = ""
            Sha256      = ""
            Required    = $true
        }
    )
}