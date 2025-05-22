import os
import sys

def main():
    os.system(" ".join(sys.argv[1:]))
    sys.exit(0)

if __name__ == "__main__":
    main()