#ifdef DEBUG
#   define LogDebug(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
// for Ex: -[LibraryController awakeFromNib] [Line 364] Hello world
#else
#   define LogDebug(...)
#endif
