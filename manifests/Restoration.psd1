@{

    Models = @(

        @{
            Name        = "RealESRGAN_x4plus"
            Category    = "upscale_models"
            Version     = "1.0"
            FileName    = "RealESRGAN_x4plus.pth"
            Uri         = "https://github.com/xinntao/Real-ESRGAN/releases/download/v0.1.0/RealESRGAN_x4plus.pth"
            Sha256      = "4FA0D38905F75AC06EB49A7951B426670021BE3018265FD191D2125DF9D682F1"
            Required    = $true
        }

        @{
            Name        = "GFPGANv1.4"
            Category    = "facerestore_models"
            Version     = "1.4"
            FileName    = "GFPGANv1.4.pth"
            Uri         = "https://github.com/TencentARC/GFPGAN/releases/download/v1.3.0/GFPGANv1.4.pth"
            Sha256      = ""
            Required    = $true
        }

        @{
            Name        = "CodeFormer"
            Category    = "facerestore_models"
            Version     = "0.1"
            FileName    = "codeformer.pth"
            Uri         = "https://github.com/sczhou/CodeFormer/releases/download/v0.1.0/codeformer.pth"
            Sha256      = ""
            Required    = $true
        }

    )

}