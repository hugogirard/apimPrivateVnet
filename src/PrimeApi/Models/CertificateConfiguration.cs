using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace PrimeApi.Models
{
    public class CertificateConfiguration
    {
        public string Issuer { get; set; }

        public string PublicKey { get; set; }
    }
}
