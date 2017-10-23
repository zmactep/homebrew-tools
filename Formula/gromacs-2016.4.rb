class Gromacs20164 < Formula
  desc "Versatile package for molecular dynamics calculations"
  homepage "http://www.gromacs.org/"
  url "https://ftp.gromacs.org/pub/gromacs/gromacs-2016.4.tar.gz"
  sha256 "4be9d3bfda0bdf3b5c53041e0b8344f7d22b75128759d9bfa9442fe65c289264"

  option "with-double", "Enables double precision"

  depends_on "cmake" => :build
  depends_on "fftw"
  depends_on "gsl"
  depends_on :mpi => :optional
  depends_on :x11 => :optional

  def install
    args = std_cmake_args + %w[-DGMX_GSL=on] + %w[-DGMX_FFT_LIBRARY=fftw3]
    args << "-DGMX_DOUBLE=on" if build.include? "enable-double"
    args << "-DGMX_MPI=on" if build.with? "mpi"
    args << "-DGMX_X11=on" if build.with? "x11"
    args << "-DGMX_GPU=on" if build.with? "cuda"
    args << "-DGMX_GPU=on -DGMX_USE_OPENCL=on" if build.with? "opencl"
    if build.with?("opencl") && build.with?("cuda")
      odie "Cannot build GROMACS with both CUDA and OpenCL support"
    end

    inreplace "scripts/CMakeLists.txt", "BIN_INSTALL_DIR", "DATA_INSTALL_DIR"

    mkdir "build" do
      system "cmake", "..", *args
      system "make"
      ENV.deparallelize { system "make", "install" }
    end

    bash_completion.install "build/scripts/GMXRC" => "gromacs-completion.bash"
    bash_completion.install "#{bin}/gmx-completion-gmx.bash" => "gmx-completion-gmx.bash"
    bash_completion.install "#{bin}/gmx-completion.bash" => "gmx-completion.bash"
    zsh_completion.install "build/scripts/GMXRC.zsh" => "_gromacs"
  end

  def caveats; <<~EOS
    GMXRC and other scripts installed to:
      #{HOMEBREW_PREFIX}/share/gromacs
    EOS
  end

  test do
    system "#{bin}/gmx", "help"
  end
end