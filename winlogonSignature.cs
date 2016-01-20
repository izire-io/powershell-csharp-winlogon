using System;
using System.Text;
using System.Runtime.InteropServices;

namespace WinLogon
{
    public static class WinLogon
    {
        [DllImport("kernel32.dll", SetLastError = true)]
        static extern uint FormatMessage(
            UInt32 flags,
            IntPtr source,
            UInt32 messageId,
            UInt32 languageId,
            StringBuilder buffer,
            UInt32 size,
            IntPtr arguments);

        [DllImport("kernel32.dll", CharSet = CharSet.Auto)]
        public extern static bool CloseHandle(IntPtr handle);

        // https://msdn.microsoft.com/en-us/library/windows/desktop/aa378184%28v=vs.85%29.aspx
        [DllImport("advapi32.dll", SetLastError = true)]
        public static extern bool LogonUser(
            string lpszUsername,
            string lpszDomain,
            string lpszPassword,
            int dwLogonType,
            int dwLogonProvider,
            out IntPtr phToken
            );

        // For FormatMessage
        private const UInt32 FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000;
        private const Int32 FORNAT_MESSAGE_BUFFER_SIZE = 512;

        public static string GetErrorMessage()
        {
            StringBuilder message = new StringBuilder(FORNAT_MESSAGE_BUFFER_SIZE);
            FormatMessage(
                FORMAT_MESSAGE_FROM_SYSTEM, // Flag to specify how to interpret the source parameter
                IntPtr.Zero,                // Source : location of the message definition (optional)
                (UInt32)System.Runtime.InteropServices.Marshal.GetLastWin32Error(),
                0,                          // Selected language
                message,                    // Buffer in which one the message will be retrieved
                (UInt32)message.Capacity,   // Buffer's size
                IntPtr.Zero);               // Arguments (optional)

            return message.ToString();
        }
    }
}
