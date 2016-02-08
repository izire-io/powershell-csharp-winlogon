using System;
using System.Text;
using System.Runtime.InteropServices;

namespace WIN32_Wrapper
{
    public static class WindowsLogon
    {
        private const UInt32 FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
        private const Int32 FORNAT_MESSAGE_BUFFER_SIZE = 512;

        /// <summary>
        /// https://msdn.microsoft.com/en-us/library/windows/desktop/ms679351(v=vs.85).aspx
        /// </summary>
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern uint FormatMessage(
            UInt32 dwFlags,
            IntPtr lpSource,
            UInt32 dwMessageId,
            UInt32 dwLanguageId,
            StringBuilder lpBuffer,
            UInt32 nSize,
            IntPtr arguments);

        /// <summary>
        /// https://msdn.microsoft.com/en-us/library/windows/desktop/ms724211(v=vs.85).aspx
        /// </summary>
        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        public extern static bool CloseHandle(IntPtr hObject);

        /// <summary>
        /// https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184%28v=vs.85%29.aspx
        /// </summary>
        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool LogonUser(
            String lpszUsername,
            String lpszDomain,
            String lpszPassword,
            Int32 dwLogonType,
            Int32 dwLogonProvider,
            out IntPtr phToken);

        /// <summary>
        /// Retrieves the last WIN32 error code and returns a corresponding error message.
        /// </summary>
        /// <returns>A WIN32 API error message.</returns>
        public static string GetErrorMessage()
        {
            StringBuilder message = new StringBuilder(FORNAT_MESSAGE_BUFFER_SIZE);
            FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, IntPtr.Zero,
                (UInt32)System.Runtime.InteropServices.Marshal.GetLastWin32Error(),
                0,message,(UInt32)message.Capacity,IntPtr.Zero);

            return message.ToString();
        }
    }
}
